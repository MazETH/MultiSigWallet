// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract MultiSigWallet {
    event TransactionSentForApproval(
        address indexed _signer,
        uint256 _txId,
        address indexed _to,
        uint256 _value,
        bytes _data
    );
    event ApprovalRevoked(address indexed _revoke, uint256 indexed _txId);
    event DepositSuccessful(address indexed _from, uint256 indexed _amount);
    event SignerAdded(address indexed _newSigner);
    event SignerRemoved(address indexed _removedSigner);
    event TransactionApproved(uint256 indexed _txId, address indexed _signer);
    address private owner;
    mapping(address => bool) isSigner;
    address[] public signers;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool execute;
        uint confirmations;
    }

    constructor(address[] memory _signers) {
        require(_signers.length > 0, "No Signers");
        for (uint i = 0; i < _signers.length; i++) {
            require(_signers[i] != address(0), "Zero Address Signer");
            require(!isSigner[_signers[i]], "Duplicate Signers Not Allowed");
            signers.push(_signers[i]);
            isSigner[_signers[i]] = true;
        }
    }

    receive() external payable {
        emit DepositSuccessful(msg.sender, msg.value);
    }
}
