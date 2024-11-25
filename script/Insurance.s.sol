// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Insurance} from "../src/Insurance.sol";

contract InsuranceScript is Script {
    Insurance public insurance;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        insurance = new Insurance();

        vm.stopBroadcast();
    }
}
