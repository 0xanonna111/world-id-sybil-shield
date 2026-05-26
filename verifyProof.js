const { ethers } = require("ethers");
require("dotenv").config();

/**
 * Encodes application validation variables to generate 
 * structural target input signatures compatible with our smart contract interface.
 */
function generateExternalNullifier(appId, actionId) {
    const abiCoder = ethers.AbiCoder.defaultAbiCoder();
    const hash = ethers.keccak256(
        abiCoder.encode(["string", "string"], [appId, actionId])
    );
    // Mask down output bytes to conform to fit neatly into uint256 boundaries
    return BigInt(hash) >> 8n;
}

const appId = process.env.WORLD_APP_ID || "app_staging_00000000000000";
const actionId = process.env.WORLD_ACTION_ID || "claim_unique_rewards";

const calculatedNullifier = generateExternalNullifier(appId, actionId);
console.log(`--- World ID Configuration Utility ---`);
console.log(`Calculated External Nullifier Parameter: ${calculatedNullifier.toString()}`);
