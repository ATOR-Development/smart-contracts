import {
  ContractError,
  ContractInteraction,
  HandlerResult
} from 'warp-contracts'

import BigNumber from 'bignumber.js'

import {
  ContractAssert,
  ContractFunctionInput,
  Evolvable,
  EvolvableState,
  INVALID_INPUT,
  OnlyOwner,
  OwnableState,
  PartialFunctionInput,
  SmartWeave,
  UPPER_HEX_CHARS
} from '../util'
import { ADDRESS_REQUIRED, Claimable, EvmAddress, INVALID_ADDRESS } from './'

export const INVALID_DISTRIBUTION_AMOUNT = 'Invalid distribution amount'
export const INVALID_TIMESTAMP = 'Invalid timestamp'
export const INVALID_SCORES = 'Invalid scores'
export const DUPLICATE_FINGERPRINT_SCORES = 'Duplicate fingerprint in scores'
export const NO_PENDING_SCORES = 'No pending scores to distribute from'
export const NO_DISTRIBUTION_TO_CANCEL = 'No distribution to cancel'
export const CANNOT_BACKDATE_SCORES = 'Cannot backdate scores'

export const DISTRIBUTION_RATE_MS = BigNumber(1000)

export type Score = {
  score: string
  address: string
  fingerprint: string
}

export type DistributionState = OwnableState & EvolvableState & {
  distributionAmount: string,
  pendingDistributions: {
    [timestamp: string]: Score[]
  },
  claimable: {
    [address: string]: string
  }
  previousDistributions: {
    [timestamp: string]: { distributionAmount: string }
  }
}

export interface SetDistributionAmount extends ContractFunctionInput {
  function: 'setDistributionAmount',
  distributionAmount: string
}

export interface AddScores extends ContractFunctionInput {
  function: 'addScores',
  timestamp: string,
  scores: Score[]
}

export interface Distribute extends ContractFunctionInput {
  function: 'distribute',
  timestamp: string
}

export interface CancelDistribution extends ContractFunctionInput {
  function: 'cancelDistribution',
  timestamp: string
}

export class DistributionContract extends Evolvable(Object) {
  private areValidScores(scores?: Score[]): scores is Score[] {
    return !!scores && scores.length > 0 && scores.every(
      ({ score, address, fingerprint }) => {
        try {
          const checksumAddress = SmartWeave.extensions.ethers.utils.getAddress(
            address
          )
          return typeof address === 'string'
            && address.length === 42
            && address === checksumAddress
            && typeof fingerprint === 'string'
            && fingerprint.length === 40
            && fingerprint.split('').every(c => UPPER_HEX_CHARS.includes(c))
            && typeof score === 'string'
            && BigNumber(score).gte(0)
        } catch (error) {
          return false
        }
      }
    )
  }

  private isValidTimestamp(timestamp: any): timestamp is string {
    return typeof timestamp === 'string'
      && timestamp.length >= 13
      && !Number.isNaN(Number.parseInt(timestamp || ''))
  }

  private getLatestDistribution(state: DistributionState): number | false {
    return Object.keys(state.previousDistributions).length > 0
      && Number.parseInt(Object.keys(state.previousDistributions).sort()[0])
  }

  private isTimestampNotBackdated(
    state: DistributionState,
    timestamp: string
  ): boolean {
    const latestDistribution = this.getLatestDistribution(state)
    
    if (latestDistribution) {
      return Number.parseInt(timestamp) > latestDistribution
    }

    return true
  }

  private assertValidEvmAddress(
    address?: string
  ): asserts address is EvmAddress {
    ContractAssert(!!address, ADDRESS_REQUIRED)
    ContractAssert(typeof address === 'string', INVALID_ADDRESS)
    ContractAssert(address.length === 42, INVALID_ADDRESS)
    
    try {
      const checksumAddress = SmartWeave.extensions.ethers.utils.getAddress(
        address
      )
      ContractAssert(address === checksumAddress, INVALID_ADDRESS)
    } catch (error) {
      throw new ContractError(INVALID_ADDRESS)
    }
  }

  @OnlyOwner
  setDistributionAmount(
    state: DistributionState,
    action: ContractInteraction<PartialFunctionInput<SetDistributionAmount>>
  ): HandlerResult<DistributionState, any> {
    const { input: { distributionAmount } } = action

    ContractAssert(
      typeof distributionAmount === 'string'
        && BigNumber(distributionAmount).gte(0),
      INVALID_DISTRIBUTION_AMOUNT
    )

    state.distributionAmount = distributionAmount

    return { state, result: true }
  }

  @OnlyOwner
  addScores(
    state: DistributionState,
    action: ContractInteraction<PartialFunctionInput<AddScores>>
  ): HandlerResult<DistributionState, any> {
    const { timestamp, scores } = action.input

    ContractAssert(this.isValidTimestamp(timestamp), INVALID_TIMESTAMP)
    ContractAssert(this.areValidScores(scores), INVALID_SCORES)
    ContractAssert(
      this.isTimestampNotBackdated(state, timestamp),
      CANNOT_BACKDATE_SCORES
    )

    if (!state.pendingDistributions[timestamp]) {
      state.pendingDistributions[timestamp] = []
    }

    for (let i = 0; i < scores.length; i++) {
      const score = scores[i]

      ContractAssert(
        !state.pendingDistributions[timestamp].find(
          ({ fingerprint }) => fingerprint === score.fingerprint
        ),
        DUPLICATE_FINGERPRINT_SCORES
      )

      state.pendingDistributions[timestamp].push(score)
    }

    return { state, result: true }
  }

  @OnlyOwner
  distribute(
    state: DistributionState,
    action: ContractInteraction<PartialFunctionInput<Distribute>>
  ): HandlerResult<DistributionState, any> {
    const { timestamp } = action.input

    ContractAssert(this.isValidTimestamp(timestamp), INVALID_TIMESTAMP)
    ContractAssert(
      !!state.pendingDistributions[timestamp]
      && state.pendingDistributions[timestamp].length > 0,
      NO_PENDING_SCORES
    )

    const lastDistribution = this.getLatestDistribution(state)
    let distributionAmount = BigNumber(state.distributionAmount)
    let totalDistributed = BigNumber(0)
    if (!lastDistribution) {
      distributionAmount = BigNumber(0)
    } else {
      const elapsedSinceLastDistribution =
        Number.parseInt(timestamp) - lastDistribution
      
      distributionAmount = BigNumber(state.distributionAmount)
        .times(BigNumber(elapsedSinceLastDistribution))
        .dividedBy(DISTRIBUTION_RATE_MS)
      
      const scores = state.pendingDistributions[timestamp]
      const total = scores.reduce<BigNumber>(
        (total, { score }) => total.plus(BigNumber(score)),
        BigNumber(0)
      )

      for (let i = 0; i < scores.length; i++) {
        const { score, address } = scores[i]
        const claimable = BigNumber(score)
          .dividedBy(total)
          .times(distributionAmount)
          .integerValue(BigNumber.ROUND_FLOOR)
        totalDistributed = totalDistributed.plus(claimable)
        const previouslyClaimable = state.claimable[address] || '0'
        state.claimable[address] = BigNumber(previouslyClaimable)
          .plus(claimable)
          .toString()
      }
    }

    state.previousDistributions[timestamp] = {
      distributionAmount: totalDistributed.toString()
    }
    delete state.pendingDistributions[timestamp]

    return { state, result: true }
  }

  @OnlyOwner
  cancelDistribution(
    state: DistributionState,
    action: ContractInteraction<PartialFunctionInput<Distribute>>
  ): HandlerResult<DistributionState, any> {
    const { timestamp } = action.input

    ContractAssert(this.isValidTimestamp(timestamp), INVALID_TIMESTAMP)
    ContractAssert(
      !!state.pendingDistributions[timestamp],
      NO_DISTRIBUTION_TO_CANCEL
    )

    delete state.pendingDistributions[timestamp]

    return { state, result: true }
  }

  claimable(
    state: DistributionState,
    action: ContractInteraction<PartialFunctionInput<Claimable>>
  ): HandlerResult<DistributionState, string> {
    const { address } = action.input

    this.assertValidEvmAddress(address)

    return {
      state,
      result: state.claimable[address] || '0'
    }
  }
}

export default function handle(
  state: DistributionState,
  action: ContractInteraction<any>
): HandlerResult<DistributionState, any> {
  const contract = new DistributionContract()

  switch (action.input.function) {
    case 'setDistributionAmount':
      return contract.setDistributionAmount(state, action)
    case 'addScores':
      return contract.addScores(state, action)
    case 'distribute':
      return contract.distribute(state, action)
    case 'cancelDistribution':
      return contract.cancelDistribution(state, action)
    case 'claimable':
      return contract.claimable(state, action)
    default:
      throw new ContractError(INVALID_INPUT)
  }
}