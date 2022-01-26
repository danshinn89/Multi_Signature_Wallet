//SPDX-License-Indentifier: MIT

pragma solidity ^0.6.6;

contract MultiSig {
    struct Transfer {
        uint256 id;
        uint256 amount;
        address payable to;
        uint256 approvals;
        bool sent;
    }
    mapping(uint256 => Transfer) public transfers;
    mapping(address => mapping(uint256 => bool)) approvals;
    uint256 nextId;

    //list of approved users
    address[] public approvers;
    uint256 public quorum;

    constructor(address[] memory _approvers, uint256 _quorum) public payable {
        approvers = _approvers;
        quorum = _quorum;
    }

    function createTransfer(uint256 amount, address payable to)
        external
        onlyApprover
    {
        // container for all transfers
        transfers[nextId] = Transfer(nextId, amount, to, 0, false);
        nextId++;
    }

    function sendTrasfer(uint256 id) external onlyApprover {
        require(transfers[id].sent == false, "Transfer been sent");
        if (transfers[id].approvals >= quorum) {
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            uint256 amount = transfers[id].amount;
            to.transfer(amount);
            return;
        }
        if (approvals[msg.sender][id] == false) {
            approvals[msg.sender][id] == true;
            transfers[id].approvals++;
        }
    }

    modifier onlyApprover() {
        bool allowed = false;
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == msg.sender) {
                allowed = true;
            }
        }
        require(allowed == true, "Only approvers allowed");
        _;
    }
}
