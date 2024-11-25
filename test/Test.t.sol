// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Insurance.sol";

contract InsuranceTest is Test {
    Insurance private insurance;
    address private insurer;
    address private user1;
    address private user2;

    function setUp() public {
        insurer = vm.addr(1); // Use this contract as the insurer
        user1 = vm.addr(2);
        // user2 = vm.addr(2);

        vm.deal(insurer, 100 ether);
        vm.deal(user1, 50 ether);
        vm.deal(user2, 50 ether);

        vm.prank(insurer);
        insurance = new Insurance();
    }

    function testAddPolicy() public {
        vm.prank(insurer);
        insurance.addPolicy("Health", 50 ether, 1 ether, 0.1 ether, 360, 720);
        (
            uint256 policyNumber,
            string memory policyType,
            uint256 coverageAmount,
            uint256 premium,
            uint256 deductibles,
            uint256 policyTerm,
            uint256 policyLifeLine
        ) = insurance.policy(1);
        assertEq(policyNumber, 1);
        assertEq(policyType, "Health");
        assertEq(coverageAmount, 50 ether);
        assertEq(premium, 1 ether);
        assertEq(deductibles, 0.1 ether);
        assertEq(policyTerm, 360);
        assertEq(policyLifeLine, 720);
    }

    function testBuyPolicy() public {
        vm.prank(insurer);
        insurance.addPolicy("Health", 50 ether, 1 ether, 0.1 ether, 360, 720);

        vm.prank(user1);
        // assertEq(address(user1).balance, 50 ether);
        // vm.deal(address(insurance), 1 ether);
        insurance.buyPolicy{value: 1 ether}("Alice", 1);

        (
            address holder,
            string memory name,
            uint256 policyNumber,
            bool claimInsurance,
            uint256 totalCoverageAmount,
            uint256 amountPaid,
            bool policyTerminated,
            ,
            uint256 lastPaymentTime
        ) = insurance.policyHolder(1);
        assertEq(holder, user1);
        assertEq(name, "Alice");
        assertEq(policyNumber, 1);
        assertEq(claimInsurance, false);
        assertEq(totalCoverageAmount, 0);
        assertEq(amountPaid, 1 ether);
        assertEq(policyTerminated, false);
        assertGt(lastPaymentTime, 0);
    }

    function testPayPolicyTimely() public {
        vm.prank(insurer);
        // insurance.addPolicy("Health", 1000 ether, 1 ether, 0.1 ether, 30, 360);
        insurance.addPolicy("Health", 50 ether, 1 ether, 0.1 ether, 30, 360);

        vm.prank(user1);
        insurance.buyPolicy{value: 1 ether}("Alice", 1);

        // skip(25 days);

        // vm.prank(user1);
        // insurance.payPolicyTimely{value: 1 ether}(1);

        (,,,,,, bool policyTerminated, uint256 startOfPolicy,) = insurance.policyHolder(1);

        // // (, , uint256 policyNumber, , uint256 amountPaid,, uint256 lastPaymentTime) = insurance.policyHolder(1);
        // // (uint256 policyNumber, string memory policyType, uint256 coverageAmount, uint256 premium, uint256 deductibles, uint256 policyTerm, uint256 policyLifeLine) = insurance.policy(1);

        // assertEq(policyNumber, 1);
        // assertEq(policyTerminated, false);
        // assertEq(claimInsurance, false);
        // assertEq(amountPaid, 2 ether);
        // assertGt(lastPaymentTime, block.timestamp - 1 days); // Ensure lastPaymentTime was recently updated

        for (uint256 i = 0; i < 15; i++) {
            // ( , , , , , , bool policyTerminated, , uint256 startOfPolicy) = insurance.policyHolder(1);

            vm.prank(user1);
            skip(25 days);
            insurance.payPolicyTimely{value: 1 ether}(1);

            if (block.timestamp > startOfPolicy + 375 days) {
                bool terminated = policyTerminated;
                assertEq(terminated, true);
                break;
            }

            // assertEq(policyTerminated, true);
        }
    }

    function testClaimInsurance() public {
        vm.prank(insurer);
        // insurance.addPolicy("Health", 1000 ether, 1 ether, 0.1 ether, 30, 360);
        insurance.addPolicy("Health", 50 ether, 1 ether, 0.1 ether, 360, 720);

        vm.prank(user1);
        insurance.buyPolicy{value: 1 ether}("Alice", 1);

        skip(355 days);

        vm.prank(user1);
        insurance.payPolicyTimely{value: 1 ether}(1);

        vm.prank(user1);
        insurance.claimInsurance("Alice", 1, 1, 1000 ether);

        (address holder,,,, uint256 totalCoverageAmount,,,, uint256 lastPaymentTimeClaim) =
            insurance.claimingPolicy(user1);
        //(address holder,, uint256 totalCoverageAmount,, uint256 lastPaymentTimeClaim) = insurance.claimingPolicy(user1);
        assertEq(holder, user1);
        assertEq(totalCoverageAmount, 1000 ether);
        assertGt(lastPaymentTimeClaim, 0);
    }

    function testApprovedInsurance() public {
        vm.prank(insurer);
        // insurance.addPolicy("Health", 1000 ether, 1 ether, 0.1 ether, 30, 360);
        insurance.addPolicy("Health", 50 ether, 1 ether, 0.1 ether, 360, 720);

        vm.prank(user1);
        insurance.buyPolicy{value: 1 ether}("Alice", 1);

        skip(355 days);

        vm.prank(user1);
        insurance.payPolicyTimely{value: 1 ether}(1);

        vm.prank(user1);
        insurance.claimInsurance("Alice", 1, 1, 1000 ether);

        vm.deal(insurer, 1000 ether);
        vm.prank(insurer);
        insurance.approvedInsurance{value: 1000 ether}("Alice", user1, 1, 1000 ether, 2 ether);

        //(address holder,, bool claimInsurance,, bool policyTerminated,) = insurance.accpetclaimingPolicy(1);
        (address holder,,, bool claimInsurance,,, bool policyTerminated,,) = insurance.accpetclaimingPolicy(1);
        assertEq(holder, user1);
        assertEq(claimInsurance, true);
        assertEq(policyTerminated, true);
    }
}
