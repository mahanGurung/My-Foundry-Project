// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Staking.sol";

contract TestStaking is Test {
    Staking private staking;
    address user1;
    address user2;
    address contractAddress;

    function setUp() public {
        user1 = vm.addr(1);
        user2 = vm.addr(2);

        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);

        // vm.prank(user1);
        staking = new Staking(5);

        contractAddress = address(staking);

        vm.deal(contractAddress, 10 ether);
    }

    function testStaking() public {
        vm.prank(user1);
        staking.staking{value: 5 ether}(365 days);
        (uint256 amount, uint256 timestamp,) = staking.stakes(user1);
        console.log(timestamp);
        assertEq(amount, 5 ether);
        assertEq(staking.viewContractBalance(), 15 ether);
    }

    function testWithdrawn() public {
        vm.prank(user1);
        staking.staking{value: 5 ether}(365 days);

        (, uint256 timestamp,) = staking.stakes(user1);
        vm.warp(timestamp + 365 days);
        // skip(365 days);
        console.log("timestamp at withdrawn", block.timestamp);
        console.log("timestamp at staking", timestamp);

        vm.prank(user1);

        console.log("Calculated Reward: ", staking.calculateReward(user1));

        vm.prank(user1);
        staking.withdrawn(3 ether);
        console.log("Rewards:", staking.rewards(user1));

        console.log("Calculated Reward: ", staking.calculateReward(user1));
        vm.prank(user1);
        (uint256 amountAfterOneyear, uint256 timestampAfterOneYear,) = staking.stakes(user1);

        assertEq(amountAfterOneyear, 2 ether);

        // vm.prank(user1);
        // vm.warp(timestampAfterOneYear + 365 days);

        // staking.withdrawn(1 ether);
        // console.log("Rewards:", staking.rewards(user1));
        // console.log("Calculated Reward: ", staking.calculateReward(user1));
        // console.log(timestampAfterOneYear);
        // assertEq(staking.viewContractBalance(), 1 ether);
    }

    function testClaimRewards() public {
        vm.prank(user1);
        staking.staking{value: 5 ether}(365 days);
        (, uint256 timestamp,) = staking.stakes(user1);

        // skip(365 days);
        vm.warp(timestamp + 365 days);

        vm.prank(user1);
        staking.withdrawn(3 ether);

        // skip(365 days);
        vm.warp(timestamp + 365 days);

        vm.prank(user1);

        (uint256 notCollectReward) = staking.rewards(user1);
        (uint256 reward) = staking.calculateReward(user1);
        uint256 totalReward = reward + notCollectReward;

        console.log("reward: ", notCollectReward);
        console.log("TotalReward", totalReward);
        vm.prank(user1);

        staking.claimReward();

        // assertEq(totalReward, 0.00000000018144 ether);
    }

    function testReward() public {
        vm.prank(user1);
        staking.staking{value: 10 ether}(365 days);
        (, uint256 timestamp,) = staking.stakes(user1);
        vm.warp(timestamp + 365 days);
        vm.prank(user1);
        console.log("CalculateReward", staking.calculateReward(user1));
        // console.log("Reward:", staking.rewards[user1]);
    }
}
