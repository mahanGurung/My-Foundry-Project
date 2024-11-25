// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Staking.sol";

contract TestStaking is Test {
    Staking private staking;
    address user1;
    address user2;

    function setUp() public {
        user1 = vm.addr(1);
        user2 = vm.addr(2);

        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);

        // vm.prank(user1);
        staking = new Staking();
    }

    function testStaking() public {
        vm.prank(user1);
        staking.staking{value: 5 ether}();
        (uint256 amount,) = staking.stakes(user1);
        assertEq(amount, 5 ether);
        assertEq(staking.viewContractBalance(), 5 ether);
    }

    function testWithdrawn() public {

        vm.prank(user1);
        staking.staking{value: 5 ether}();

        vm.prank(user1);
        staking.withdrawn(3 ether);
        (uint256 amount,) = staking.stakes(user1);
        assertEq(amount, 2 ether);
        assertEq(staking.viewContractBalance(), 2 ether);

    }

    function testClaimRewards() public {
         vm.prank(user1);
        staking.staking{value: 5 ether}();

        vm.prank(user1);
        staking.withdrawn(3 ether);

        vm.prank(user1);
        staking.claimReward();
        
        uint256 totalReward = staking.calculateReward(user1) + staking.rewards(user1);
        assertEq(totalReward, 3 ether);

    }
}
