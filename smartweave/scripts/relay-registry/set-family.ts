import dotenv from 'dotenv'
import { LoggerFactory, WarpFactory } from 'warp-contracts'
import EthereumSigner from 'arbundles/src/signing/chains/ethereumSigner'
import { EthersExtension } from 'warp-contracts-plugin-ethers'
import { Wallet } from 'ethers'
import Consul from 'consul'
import BigNumber from 'bignumber.js'

import {
  RelayRegistryHandle,
  RelayRegistryState
} from '../../src/contracts'
import { SetFamily } from '~/src/contracts/relay-registry'

dotenv.config()

let contractTxId = process.env.RELAY_REGISTRY_CONTRACT_ID || ''
const consulToken = process.env.CONSUL_TOKEN
const contractOwnerPrivateKey = process.env.RELAY_REGISTRY_OWNER_KEY
const fingerprint = process.env.FINGERPRINT || ''
const family = process.env.FAMILY

LoggerFactory.INST.logLevel('error')
BigNumber.config({ EXPONENTIAL_AT: 50 })

const warp = WarpFactory
  .forMainnet()
  .use(new EthersExtension())

async function main() {
  if (!contractTxId) {
    throw new Error('RELAY_REGISTRY_CONTRACT_ID is not set!')
  }

  if (!contractOwnerPrivateKey) {
    throw new Error('RELAY_REGISTRY_OWNER_KEY is not set!')
  }

  if (!fingerprint) {
    throw new Error('FINGERPRINT is not set!')
  }

  if (!family && family !== '') {
    throw new Error('FAMILY is not set!')
  }

  const contract = warp.contract<RelayRegistryState>(contractTxId)

  const input: SetFamily = {
    function: 'setFamily',
    fingerprint,
    family: family.split(',').filter(f => !!f)
  }

  // NB: Sanity check dry run
  const { cachedValue: { state } } = await contract.readState()
  RelayRegistryHandle(state, {
    input,
    caller: new Wallet(contractOwnerPrivateKey).address,
    interactionType: 'write'
  })

  // NB: Send real interaction
  await contract
    .connect(new EthereumSigner(contractOwnerPrivateKey))
    .writeInteraction<SetFamily>(input)
}

(async () => {
  try {
    await main()
  } catch (error) {
    console.error('Set Family script error', error)
    process.exitCode = 1
  }
})()