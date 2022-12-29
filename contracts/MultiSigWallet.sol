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
    mapping(uint256 => mapping(address => bool)) transactionId;
    address[] public signers;
    Transaction[] public transactions;
    uint256 public idCount;

    struct Transaction {
        address payable to;
        uint256 value;
        bytes data;
        bool execute;
        uint confirmations;
        uint id;
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

    function initiateTransaction(
        address payable _to,
        uint256 _amount,
        bytes calldata _callData
    ) external {
        Transaction memory newTransaction = Transaction({
            to: _to,
            value: _amount,
            data: _callData,
            execute: false,
            confirmations: 0,
            id: idCount++
        });

        transactions.push(newTransaction);
    }

    function signTransaction(uint256 _txId) external {
        require(
            checkId(_txId),
            "This transaction ID does not exist or has already been executed"
        );
        require(
            isSigner[msg.sender],
            "Address not permitted to sign transaction"
        );
        uint256 transactionIndex = getTransactionIndex(_txId);
        bool isSigned = transactionId[_txId][msg.sender];
        require(!isSigned, "Signer has already signed this tranasction");
        transactionId[_txId][msg.sender] = true;
        transactions[transactionIndex].confirmations++;
    }

    function checkId(uint256 _txId) internal view returns (bool isId) {
        for (uint256 i = 0; i < transactions.length; i++) {
            if (transactions[i].id == _txId) {
                isId = true;
            }
        }
    }

    function executeTransaction(uint256 _txId) public payable {
        require(
            checkId(_txId),
            "This transaction ID does not exist or has already been executed"
        );
        uint256 transactionIndex = getTransactionIndex(_txId);
        require(
            transactions[transactionIndex].confirmations == signers.length,
            "This transaction has an insufficient amount of signers"
        );
        uint256 valueSend = transactions[transactionIndex].value;
        address payable sendTo = transactions[transactionIndex].to;
        (bool success, ) = sendTo.call{value: valueSend}("");
        require(success, "Transfer failed");
        delete transactions[transactionIndex];
    }

    function getTransactionIndex(
        uint256 _txId
    ) public view returns (uint256 _transactionIndex) {
        require(
            checkId(_txId),
            "This transaction ID does not exist or has already been executed"
        );
        for (uint256 i = 0; i < transactions.length; i++) {
            if (transactions[i].id == _txId) {
                _transactionIndex = i;
                i = transactions.length;
            }
        }
    }

    receive() external payable {
        emit DepositSuccessful(msg.sender, msg.value);
    }
}
