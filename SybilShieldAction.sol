// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IWorldID {
    /**
     * @notice Verifies a WorldID execution proof.
     * @param root The core cryptographic root of the identity Merkle tree.
     * @param signal An arbitrary commitment hash tied to this transaction sequence.
     * @param nullifierHash The unique identifier preventing double-actions.
     * @param proof The actual snark proof array.
     */
    function verifyProof(
        uint256 root,
        uint256 signal,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) external view;
}

contract SybilShieldAction {
    IWorldID public immutable worldIdRouter;
    uint256 public immutable externalNullifier;
    
    // Tracks uniqueness across individual identities to stop double-claims
    mapping(uint256 => bool) public claimedNullifiers;

    event HumanVerified(uint256 indexed nullifierHash, address indexed user);

    constructor(address _worldIdRouter, uint256 _externalNullifier) {
        worldIdRouter = IWorldID(_worldIdRouter);
        externalNullifier = _externalNullifier;
    }

    /**
     * @notice Validates the ZK-Proof from World ID to process a unique action.
     */
    function executeUniqueAction(
        address receiver,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) external {
        require(!claimedNullifiers[nullifierHash], "SybilShield: Identity has already performed this action");

        // Construct signal commitment binding this unique proof execution directly to the receiver wallet address
        uint256 signalHash = uint256(keccak256(abi.encodePacked(receiver)));

        // Call out to WorldID router implementation components to evaluate verification status
        worldIdRouter.verifyProof(
            root,
            signalHash,
            nullifierHash,
            proof
        );

        // Commit nullifier to storage to prevent dynamic re-entry attacks or duplicates
        claimedNullifiers[nullifierHash] = true;

        emit HumanVerified(nullifierHash, receiver);
    }
}
