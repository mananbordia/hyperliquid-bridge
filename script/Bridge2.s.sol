// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Bridge2} from "../src/Bridge2.sol";

contract Bridge2Script is Script {
    Bridge2 public bridge;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address[] memory hot = new address[](2);
        address[] memory cold = new address[](2);
        uint64[] memory powers = new uint64[](2);

        hot[0] = address(0x1001);
        hot[1] = address(0x1002);
        cold[0] = address(0x2001);
        cold[1] = address(0x2002);
        powers[0] = uint64(1);
        powers[1] = uint64(2);

        address usdc = address(0xDEAD);
        uint64 disputePeriodSeconds = uint64(3600);
        uint64 blockDurationMillis = uint64(1000);
        uint64 lockerThreshold = uint64(1);

        bridge = new Bridge2(hot, cold, powers, usdc, disputePeriodSeconds, blockDurationMillis, lockerThreshold);

        vm.stopBroadcast();
    }
}
