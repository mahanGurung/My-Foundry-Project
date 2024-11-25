//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Staking {
    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Stake) public stakes;
    mapping(address => uint256) public rewards;

    uint256 public rewardRate = 100;

    function staking() public payable {
        require(msg.value > 0, "You must send some Ether");
        stakes[msg.sender].amount = msg.value;
        stakes[msg.sender].timestamp = block.timestamp;
    }

    function calculateReward(address _staker) public view returns (uint256) {
        Stake memory stakeData = stakes[_staker];
        uint256 stakeTime = block.timestamp - stakeData.timestamp;
        uint256 totalReward = stakeData.amount * stakeTime * rewardRate;
        return totalReward / 1e18;
    }

    function withdrawn(uint256 _amount) public payable {
        // Stake memory stakeData = stakes[msg.sender];
        require(stakes[msg.sender].amount > 0, "User don't have stake");

        uint256 reward = calculateReward(msg.sender);
        rewards[msg.sender] += reward;

        stakes[msg.sender].amount -= _amount;
        stakes[msg.sender].timestamp = block.timestamp;

        payable(msg.sender).transfer(_amount);
    }

    function claimReward() public payable {
        uint256 reward = calculateReward(msg.sender) + rewards[msg.sender];
        rewards[msg.sender] = 0;

        stakes[msg.sender].timestamp = block.timestamp;

        payable(msg.sender).transfer(reward);
    }

    function viewContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
