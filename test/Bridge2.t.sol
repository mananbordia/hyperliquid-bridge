// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Bridge2} from "../src/Bridge2.sol";

contract Bridge2Test is Test {
    Bridge2 public bridge;

    function setUp() public {
        address[] memory hot = new address[](2);
        address[] memory cold = new address[](2);
        uint64[] memory powers = new uint64[](2);

        hot[0] = address(0x1001);
        hot[1] = address(0x1002);
        cold[0] = address(0x2001);
        cold[1] = address(0x2002);
        powers[0] = 1;
        powers[1] = 2;

        // usdcAddress can be a dummy address for constructor initialization
        address usdc = address(0xDEAD);
        uint64 disputePeriodSeconds = 3600;
        uint64 blockDurationMillis = 1000;
        uint64 lockerThreshold = 1;

        bridge = new Bridge2(hot, cold, powers, usdc, disputePeriodSeconds, blockDurationMillis, lockerThreshold);
    }

    function test_constructor_sets_validator_fields() public {
        // nValidators should equal length of supplied hot addresses
        assertEq(bridge.nValidators(), 2);

        // totalValidatorPower should equal sum(powers)
        assertEq(bridge.totalValidatorPower(), uint64(3));

        // epoch initialized to 0
        assertEq(bridge.epoch(), 0);

        // disputePeriodSeconds and blockDurationMillis set from constructor
        assertEq(bridge.disputePeriodSeconds(), uint64(3600));
        assertEq(bridge.blockDurationMillis(), uint64(1000));

        // hot and cold validator set hashes must be non-zero
        bytes32 hotHash = bridge.hotValidatorSetHash();
        bytes32 coldHash = bridge.coldValidatorSetHash();
        assertTrue(hotHash != bytes32(0));
        assertTrue(coldHash != bytes32(0));
    }
}
