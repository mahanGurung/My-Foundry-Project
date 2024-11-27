//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Staking {
    struct Stake {
        uint256 amount;
        uint256 timestamp;
        uint256 durations;
    }

    uint256 public annualRewardRate;

    modifier onlyStaker() {
        require(stakes[msg.sender].amount > 0 || sta, "Only staker can claim and withdrawn");
        _;
    }

    mapping(address => Stake) public stakes;
    mapping(address => uint256) public rewards;

    constructor(uint256 _annualRewardRate) {
        annualRewardRate = _annualRewardRate;
    }

    function updateAnnualRewardRate(uint256 _updateAnnualRewardRate) public {
        annualRewardRate = _updateAnnualRewardRate;
    }

    uint256 public rewardRate = 100;

    

    function staking(uint256 _durations) public payable {
        require(msg.value > 0, "You must send some Ether");
        stakes[msg.sender].amount = msg.value;
        stakes[msg.sender].timestamp = block.timestamp;
        stakes[msg.sender].durations = _durations;
    }

    // function calculateReward(address _staker) public view returns (uint256) {
    //     Stake memory stakeData = stakes[_staker];
    //     uint256 dailyRewardRate = annualRewardRate  / 36500;
    //     uint256 individualShare = stakeData.amount / viewContractBalance();
    //     uint256 stakeTime = block.timestamp - stakeData.timestamp;
    //     uint256 totalReward = (stakeData.amount * (stakeTime / 86400) * dailyRewardRate) * individualShare;
    //     return totalReward;
    // }

    function calculateReward(address _staker) public view returns (uint256) {
        Stake memory stakeData = stakes[_staker];
        uint256 dailyRewardRate = (annualRewardRate * 1e18) / 36500;
        uint256 individualShare = (stakeData.amount * 1e18) / viewContractBalance();
        uint256 stakeTimeInDays = (block.timestamp - stakeData.timestamp) / 1 days;

        // Debug logs
        // console.log("dailyRewardRate: ", dailyRewardRate);
        // console.log("individualShare: ", individualShare);
        // console.log("stakeTimeInDays: ", stakeTimeInDays);

        uint256 totalReward = (stakeData.amount * dailyRewardRate * stakeTimeInDays * individualShare) / (1e18 * 1e18);
        return totalReward;
    }

    // function calculateTotalRewards(address _staker) public view returns (uint256) {
    //     Stake memory stakeData = stakes[_staker];
    //     uint256 timeElapsed = block.timestamp - stakeData.timestamp;
    //     uint256 effectiveBalanceRewards = validatorEffectiveBalance * networkAPR * (1 - moduleFee) * timeElapsed;
    //     uint256 bondRewards = bondAmount * (shareRateChange - 1);
    //     return (effectiveBalanceRewards + bondRewards) / 1e18;
    // }

    function withdrawn(uint256 _amount) public payable onlyStaker() {
        // Stake memory stakeData = stakes[msg.sender];
        require(stakes[msg.sender].amount > 0, "User don't have stake");
        require(
            stakes[msg.sender].durations >= block.timestamp - stakes[msg.sender].timestamp,
            "withdrawn duration not finished so it is locked"
        );

        uint256 reward = calculateReward(msg.sender);
        rewards[msg.sender] += reward;

        stakes[msg.sender].amount -= _amount;
        stakes[msg.sender].timestamp = block.timestamp;

        payable(msg.sender).transfer(_amount);
    }

    function claimReward() public payable onlyStaker() {
        require(
            stakes[msg.sender].durations >= block.timestamp - stakes[msg.sender].timestamp,
            "withdrawn duration not finished so it is locked"
        );
        uint256 reward = calculateReward(msg.sender) + rewards[msg.sender];
        rewards[msg.sender] = 0;

        stakes[msg.sender].timestamp = block.timestamp;

        payable(msg.sender).transfer(reward);
    }

    function viewContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
