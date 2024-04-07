// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {SideEntranceLenderPool} from "./SideEntranceLenderPool.sol";

contract MaliciousContract is SideEntranceLenderPool {
    SideEntranceLenderPool public pool;
    address payable public attacker;

    constructor(address payable _attacker, address _pool) {
        pool = SideEntranceLenderPool(_pool);
        attacker = _attacker;
    }
}
