import fs from 'fs'
import path from 'path'
import {
  LoggerFactory,
  WarpFactory
} from 'warp-contracts'
import { DeployPlugin, EthereumSigner } from 'warp-contracts-plugin-deploy'
import { EthersExtension } from 'warp-contracts-plugin-ethers'
import {
  EvmSignatureVerificationServerPlugin
  // @ts-ignore
} from 'warp-contracts-plugin-signature/server'

import HardhatKeys from './test-keys/hardhat.json'
import Consul from "consul";

const pathToContractSrc = process.env.CONTRACT_SRC
  || '../dist/contracts/relay-registry.js'
const pathToInitState = process.env.INIT_STATE
  || '../dist/contracts/relay-registry-init-state.json'
const deployerPrivateKey = process.env.DEPLOYER_PRIVATE_KEY
  || HardhatKeys.owner.key

;(async () => {
  LoggerFactory.INST.logLevel('error')  

  const warp = WarpFactory
    .forMainnet()
    .use(new EthersExtension())
    .use(new DeployPlugin())
    .use(new EvmSignatureVerificationServerPlugin())

  const wallet = new EthereumSigner(deployerPrivateKey)

  const src: string = fs.readFileSync(
    path.join(__dirname, pathToContractSrc)
  ).toString()

  const initState: string = fs.readFileSync(
    path.join(__dirname, pathToInitState)
  ).toString()

  const {
    contractTxId,
    srcTxId
  } = await warp.deploy({ wallet, src, initState })
  
  console.log(`Contract source published at ${srcTxId}`)
  console.log(`Contract deployed at ${contractTxId}`)

  if (process.env.PHASE !== undefined && process.env.CONSUL_IP !== undefined) {
    console.log(`Connecting to Consult at ${process.env.CONSUL_IP}:${process.env.CONSUL_PORT}`)
    const consul = new Consul({
      host: process.env.CONSUL_IP,
      port: process.env.CONSUL_PORT
    });

    const updateResult = await consul.kv.set(`smart-contracts/${process.env.PHASE}/relay-registry-address`, contractTxId);
    console.log(`Cluster variable updated: ${updateResult}`)
  } else {
    console.warn('Deployment env var PHASE not defined, skipping update of cluster variable in Consul.')
  }
})()
