# ATOR SmartWeave Contracts

## Install

```bash
$ npm i
```

## Build

```bash
$ npm run build
```

## Test

```bash
$ npm run test
```

(Note, e2e test deploys to Arweave mainnet)
```bash
$ npm run test:e2e
```

## Deploy

Before deploying, make sure the following environment variables are set:

- `CONTRACT_SRC`
  - Path to contract src relative to deploy script
  - e.g. `../dist/contracts/relay-registry.js`
- `INIT_STATE`
  - Path to contract initial state JSON
  - e.g. `../scripts/test-states/relay-registry-init-state.json`
- `DEPLOYER_PRIVATE_KEY`
  - EVM deployer private key hex
  - Defaults to Hardhat Account #0

```bash
$ npm run deploy
```

## Evolve

Before evolving a contract, make sure the following environment variables are set:

- `CONTRACT_ID`
  - The ID of the contract being evolved
  - e.g. `Y6xd_xJ4EWc9F63UVC87huczSR3-RTaVxKwIXtbfGwE`
- `CONTRACT_SRC`
  - Path to new contract src relative to deploy script
  - e.g. `../dist/contracts/relay-registry.js`
- `DEPLOYER_PRIVATE_KEY`
  - EVM deployer private key hex
  - Defaults to Hardhat Account #0

```bash
$ npm run evolve
```

## Contracts

### Relay Registry

#### State

```typescript
type Fingerprint = string
type EvmAddress = string
type PublicKey = string
type RelayRegistryState = {
  owner: string
  canEvolve?: boolean
  evolve?: string
  claimable: { [fingerprint in Fingerprint as string]: EvmAddress }
  verified: { [fingerprint in Fingerprint as string]: EvmAddress }
  registrationCredits: { [address in EvmAddress as string]: Fingerprint[] }
  blockedAddresses: EvmAddress[]
  families: { [fingerprint in Fingerprint as string]: Fingerprint[] }
  registrationCreditsRequired: boolean
  encryptionPublicKey: string
  verifiedHardware: Set<Fingerprint>
  familyRequired: boolean
  nicknames: { [fingerprint in Fingerprint as string]: string }
}
```

#### Methods

- Owner/Validator adds a fingerprint/address tuple as claimable
  ```typescript
  // @OnlyOwner
  addClaimable(
    fingerprint: string,
    address: string,
    hardwareVerified?: boolean,
    nickname?: string
  ) => void
  ```

- Owner/Validator adds a BATCH of fingerprint/address tuples as claimable
  ```typescript
  // @OnlyOwner
  addClaimableBatched({
    fingerprint: string,
    address: string,
    hardwareVerified?: boolean,
    nickname?: string
  }[]) => void
  ```

- Owner/Validator removes a fingerprint/address tuple as claimable
  ```typescript
  // @OnlyOwner
  removeClaimable(fingerprint: string) => void
  ```

- View method to return either
  1) The current claimable fingerprint/address tuples
  2) A list of fingerprints claimable by the provided address
  ```typescript
  claimable(address?: string) => ClaimableRelays | Fingerprint[]
  ```

- View method to check if a fingerprint/address tuple is claimable
  ```typescript
  isClaimable(fingerprint: string, address: string) => boolean
  ```

- Claims a fingerprint if claimable by the caller's EVM address
  ```typescript
  claim(fingerprint: string) => void
  ```

- Renounces a verified fingerprint/address claim if currently verified by the caller's EVM address
  ```typescript
  renounce(fingerprint: string) => void
  ```

- Allows Owner to remove stale verifications
  ```typescript
  // @OnlyOwner
  removeVerified(fingerprint) => void
  ```

- View method to return either
  1) The current verified fingerprint/address tuples
  2) A list of fingerprints claimed/verified by the provided address
  ```typescript
  verified(address?: string) => VerifiedRelays | Fingerprint[]
  ```

- View method to check if a fingerprint is verified
  ```typescript
  isVerified(fingerprint: string) => boolean
  ```

- Allows Owner to add registration credits
  ```typescript
  addRegistrationCredits(
    credits: { address: EvmAddress, fingerprint: Fingerprint }[]
  ) => void
  ```

- Allows Owner to remove registration credits
  ```typescript
  removeRegistrationCredits(
    credits: { address: EvmAddress, fingerprint: Fingerprint }[]
  ) => void
  ```

- Allows Owner to block an address from registering
  ```typescript
  blockAddress(address: string) => void
  ```

- Allows Owner to unblock an address from registering
  ```typescript
  unblockAddress(address: string) => void
  ```

- Allows Owner to set relay families
  ```typescript
  setFamilies(
    families: {
      fingerprint: string,
      add?: Fingerprint[],
      remove?: Fingerprint[]
    }[]
  ) => void
  ```

- Allows Owner to toggle registration credits requirement to claim a relay
  ```typescript
  toggleRegistrationCreditRequirement(enabled: boolean) => void
  ```

- Allows Owner to set the encryption public key for passing secrets
  ```typescript
  setEncryptionPublicKey(encryptionPublicKey: PublicKey) => void
  ```

- Allows Owner to verify a hardware serials by fingerprints
  ```typescript
  verifySerials(fingerprints: Fingerprint[]) => void
  ```

- Allows Owner to remove a hardware serials by fingerprints
  ```typescript
  removeSerials(fingerprints: Fingerprint[]) => void
  ```

- View method to get verified relays and verified relays with verified serial
  proofs
  ```typescript
  getVerifiedRelays() => {
    verified: { [fingerprint in Fingerprint as string]: EvmAddress }
    verifiedHardware: { [fingerprint in Fingerprint as string]: EvmAddress }
  }
  ```
- Allows Owner to toggle family registration requirements to claim a relay
  ```typescript
  toggleFamilyRequirement(enabled: boolean) => void
  ```

### Distribution

#### State

```typescript
type Fingerprint = string
type EvmAddress = string
type Score = {
  score: string
  address: EvmAddress
  fingerprint: Fingerprint
}
type DistributionResult = {
  timeElapsed: string
  tokensDistributedPerSecond: string
  baseNetworkScore: string
  baseDistributedTokens: string
  bonuses: {
    hardware: {
      enabled: boolean
      tokensDistributedPerSecond: string
      networkScore: string
      distributedTokens: string
    }
    quality: {
      enabled: boolean
      tokensDistributedPerSecond: string
      settings: {
        uptime: {
          [days: number]: number
        }
      }
      uptime: {
        [fingerprint: Fingerprint]: number
      }
      networkScore: string
      distributedTokens: string
    }
  }
  multipliers: {
    family: {
      enabled: boolean
      familyMultiplierRate: string
    }
  }
  families: { [fingerprint in Fingerprint as string]: Fingerprint[] }
  totalTokensDistributedPerSecond: string
  totalNetworkScore: string
  totalDistributedTokens: string
  details: {
    [fingerprint: Fingerprint]: {
      address: EvmAddress
      score: string
      distributedTokens: string
      bonuses: {
        hardware: string
        quality: string
      }
      multipliers: {
        family: string
        region: string
      }
    }
  }
}
type DistributionState = {
  owner: string
  canEvolve?: boolean
  evolve?: string
  tokensDistributedPerSecond: string
  bonuses: {
    hardware: {
      enabled: boolean
      tokensDistributedPerSecond: string
      fingerprints: Fingerprint[]
    },
    quality: {
      enabled: boolean
      tokensDistributedPerSecond: string
      settings: {
        uptime: {
          [days: number]: number
        }
      }
      uptime: {
        [fingerprint: Fingerprint]: number
      }
    }
  }
  pendingDistributions: {
    [timestamp: string]: { scores: Score[] }
  }
  claimable: {
    [address: EvmAddress]: string
  }
  previousDistributions: {
    [timestamp: string]: DistributionResult
  }
  previousDistributionsTrackingLimit: number
  families: { [fingerprint in Fingerprint as string]: Fingerprint[] }
  multipliers: {
    family: {
      enabled: boolean
      familyMultiplierRate: string
    }
  }
}
```

#### Methods

- Allows Owner to set the token distribution rate **in atomic units** per second
  ```typescript
  setTokenDistributionRate(tokensDistributedPerSecond: string) => void
  ```

- Allows Owner to add scores used in distribution calculations
  ```typescript
  addScores(
    timestamp: string,
    scores: { score: string, address: string, fingerprint: string }[]
  ) => void
  ```

- Allows Owner to distribute pending scores for a `timestamp` key
  ```typescript
  distribute(timestamp: string) => void
  ```

- Allows Owner to cancel a pending distribution for a `timestamp` key
  ```typescript
  cancelDistribution(timestamp: string) => void
  ```

- Allows Owner to set hardware bonus distribution rate **in atomic units** per
  second
  ```typescript
  setHardwareBonusRate(tokensDistributedPerSecond: string) => void
  ```

- Allows Owner to set quality bonus distribution rate **in atomic units** per
  second
  ```typescript
  setQualityTierBonusRate(tokensDistributedPerSecond: string) => void
  ```

- Allows Owner to toggle hardware bonus on or off
  ```typescript
  toggleHardwareBonus(enabled: boolean) => void
  ```

- Allows Owner to toggle quality bonus on or off
  ```typescript
  toggleQualityTierBonus(enabled: boolean) => void
  ```

- Allows Owner to set quality bonus settings
  ```typescript
  setQualityTierBonusSettings(
    settings: { uptime: { [days: number]: number } }
  ) => void
  ```

- Allows Owner to add fingerprints to a bonus pool.  Currently only 'hardware'
  ```typescript
  addFingerprintsToBonus(
    bonusName: 'hardware',
    fingerprints: Fingerprint[]
  ) => void
  ```

- Allows Owner to set fingerprint uptimes for quality bonus
  ```typescript
  setQualityTierUptimes(uptimes: { [fingerprint: Fingerprint]: number }) => void
  ```

- Allows Owner to remove fingerprints from a bonus pool.  Currently only
  'hardware'
  ```typescript
  removeFingerprintsFromBonus(
    bonusName: 'hardware',
    fingerprints: Fingerprint[]
  ) => void
  ```

- Allows Owner to set the cumulative family multiplier rate
  ```typescript
  setFamilyMultiplierRate(familyMultiplierRate: string) => void
  ```

- Allows Owner to set relay families in distribution for family multipliers
  ```typescript
  setFamilies(
    families: {
      fingerprint: Fingerprint,
      add?: Fingerprint[],
      remove?: Fingerprint[]
    }[]
  ) => void
  ```

- Allows Owner to toggle family multipliers on/off
  ```typescript
  toggleFamilyMultipliers(enabled: boolean) => void
  ```

- Allows Owner to limit the number of previous distributions tracked in contract state.  Defaults to `10`
  ```typescript
  setPreviousDistributionTrackingLimit(limit: number) => void
  ```

- View method for getting claimable (lifetime redeemable) tokens for an address
  ```typescript
  claimable(address: EvmAddress) => string
  ```
