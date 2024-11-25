// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Insurance {
    address public insurer;

    constructor() {
        insurer = msg.sender;
    }

    modifier onlyInsurer() {
        require(msg.sender == insurer, "only insurer can add the insurence policy");
        _;
    }

    struct Policy {
        uint256 policyNumber;
        string policyType; //The type of insurance (e.g., health, vehicle, property).
        uint256 coverageAmount; //The maximum amount the insurer will pay out in case of a claim.
        uint256 premium; //The amount the policyholder pays for the insurance coverage, typically monthly or annually.
        uint256 deductibles; //The amount the policyholder must pay out-of-pocket before the insurer covers the remaining costs.
        uint256 policyTerm; //Specified period for term life insurance.
        uint256 policyLifeLine; //Specified time of life insurance,
    }

    struct PolicyHolder {
        address holder;
        string name;
        uint256 policyNumber;
        bool claimInsurance;
        uint256 totalcoverageAmount;
        uint256 amountPaid;
        bool policyTerminated;
        uint256 startOfPolicy;
        uint256 lastPaymentTime;
    }

    mapping(uint256 => Policy) public policy;
    uint256 public policyCount;

    mapping(uint256 => PolicyHolder) public policyHolder;
    uint256 public policyHolderCount;

    mapping(address => PolicyHolder) public claimingPolicy;
    // uint256 public claimingPolicyCount;

    mapping(uint256 => PolicyHolder) public accpetclaimingPolicy;
    uint256 public accpetclaimingPolicyCount;

    function addPolicy(
        string memory _policyType,
        uint256 _covrageAmount,
        uint256 _premium,
        uint256 _deductibles,
        uint256 _policyTerm,
        uint256 _policyLifeLine
    ) public onlyInsurer {
        policyCount++;
        policy[policyCount] =
            Policy(policyCount, _policyType, _covrageAmount, _premium, _deductibles, _policyTerm, _policyLifeLine);
    }

    function buyPolicy(string memory _name, uint256 _policyNumber) public payable {
        require(msg.sender != insurer, "Insurer can't buy it's own policy");
        require(msg.value >= policy[_policyNumber].premium, "Payment amount is incorrect");

        // uint256 amount = _amountPaid > 0 ? _amountPaid : 0;

        // uint256 totalcoverageAmount = _amountPaid > 0 ? policy[_policyNumber].coverageAmount : policy[_policyNumber].coverageAmount - _amountPaid ;

        policyHolderCount++;
        policyHolder[policyHolderCount] = PolicyHolder(
            msg.sender,
            _name,
            _policyNumber,
            false,
            0,
            policy[_policyNumber].premium,
            false,
            block.timestamp,
            block.timestamp
        );
        // (bool success,) = insurer.call{value: msg.value}("");
        // require(success, "Transfer failed.");
        require(address(this).balance >= msg.value, "Insufficient balance in contract");
        (bool success,) = insurer.call{value: msg.value}("");
        require(success, "Transfer failed.");
    }

    // function payPolicyTimely (uint256 _id) public payable {
    //     require(msg.sender != insurer, "Insurer can't pay it's own policy");
    //     require(msg.value >= policy[_id].premium, "Payment amount is incorrect");
    //     require(policyHolder[_id].policyTerminated  == false, "Policy has been terminated");
    //     require(policyHolder[_id].claimInsurance == false, "Policy has been claim");

    //     uint256 timeElapsed = block.timestamp - policyHolder[_id].lastPaymentTime;
    //     uint256 minimumTime = policy[_id].policyTerm - 10 days;
    //     uint256 maximumTime = policy[_id].policyTerm * 1 days;
    //     uint256 policyTime = policy[_id].policyLifeLine * 1 days;

    //     require(timeElapsed > minimumTime, "Payment is too early");
    //     // require(timeElapsed <=  maximumTime, "Payment is too late");

    //     if (timeElapsed > maximumTime || timeElapsed > policyTime) {
    //         policyHolder[_id].policyTerminated = true;
    //     }else if (timeElapsed <=  maximumTime) {
    //         // uint256 amount = policyHolder[_id].amountPaid > 0 ? policyHolder[_id].amountPaid : 0;

    //         policyHolder[_id].lastPaymentTime = block.timestamp;
    //         policyHolder[_id].amountPaid = policy[_id].premium + policyHolder[_id].amountPaid;
    //         // payable(insurer).transfer(policy[_id].premium);
    //         (bool success, ) = insurer.call{value: msg.value}("");
    //         require(success, "Transfer failed.");
    //     }
    // }

    function payPolicyTimely(uint256 _id) public payable {
        require(msg.sender != insurer, "Insurer can't pay its own policy");
        require(msg.value >= policy[_id].premium, "Payment amount is incorrect");
        require(!policyHolder[_id].policyTerminated, "Policy has been terminated");
        require(!policyHolder[_id].claimInsurance, "Policy has been claimed");

        uint256 timeElapsed = block.timestamp - policyHolder[_id].lastPaymentTime;
        uint256 minimumTime = policy[_id].policyTerm * 1 days - 10 days;
        uint256 maximumTime = policy[_id].policyTerm * 1 days;
        uint256 policyTimeEnd = policy[_id].policyLifeLine * 1 days;
        uint256 totalTime = block.timestamp - policyHolder[_id].startOfPolicy;

        require(timeElapsed > minimumTime, "Payment is too early");

        if (timeElapsed > maximumTime || totalTime > policyTimeEnd) {
            policyHolder[_id].policyTerminated = true;
        } else if (timeElapsed <= maximumTime) {
            policyHolder[_id].lastPaymentTime = block.timestamp;
            policyHolder[_id].amountPaid = policy[_id].premium + policyHolder[_id].amountPaid;

            (bool success,) = insurer.call{value: msg.value}("");
            require(success, "Transfer failed.");
        }
    }

    function claimInsurance(
        string memory _name,
        uint256 _policyHolderNumber,
        uint256 _policyNumber,
        uint256 _totalAmount
    ) public {
        require(policyHolder[_policyHolderNumber].policyTerminated == false, "Policy has been terminated");
        // require(policyHolder[_policyNumber].claimInsurance == false, "Policy has been claim");
        require(msg.sender != insurer, "Insurer can't pay it's own policy");

        claimingPolicy[msg.sender] = PolicyHolder(
            msg.sender,
            _name,
            _policyNumber,
            false,
            _totalAmount,
            policyHolder[_policyHolderNumber].amountPaid,
            false,
            policyHolder[_policyHolderNumber].startOfPolicy,
            block.timestamp
        );
    }

    function approvedInsurance(
        string memory _name,
        address _policyHolderAdd,
        uint256 _policyNumber,
        uint256 _totalAmount,
        uint256 _amountPaid
    ) public payable onlyInsurer {
        require(msg.value >= claimingPolicy[_policyHolderAdd].totalcoverageAmount, "Payment amount is incorrect");

        accpetclaimingPolicyCount++;
        accpetclaimingPolicy[accpetclaimingPolicyCount] = PolicyHolder(
            claimingPolicy[_policyHolderAdd].holder,
            _name,
            _policyNumber,
            true,
            _totalAmount,
            _amountPaid,
            true,
            claimingPolicy[_policyHolderAdd].startOfPolicy,
            block.timestamp
        );
        (bool success,) = claimingPolicy[_policyHolderAdd].holder.call{value: msg.value}("");
        require(success, "Transfer failed.");
    }
}
