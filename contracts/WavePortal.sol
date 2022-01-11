// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    uint256 private seed;

    mapping(address => uint256) wavesMap;

    mapping(address => uint256) public lastWavedAt;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
    }

    Wave[] waves;

    constructor() payable {
        console.log("Yo yo, I am a contract and I am smart");

        /**
         * set the initial seed
         */
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {

        /**
         * We need to make sure that the current timestamp is <15 minutes
         */
         require(lastWavedAt[msg.sender] + 30 seconds < block.timestamp, "Must Wait 30 seconds before waving again");

         /**
         * Update the last waved at timestamp
          */
          lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        wavesMap[msg.sender] += 1;

        console.log("%s waved w/ message: %s", msg.sender, _message);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        /**
         * Generate a new seed for the next user that sends a wave
         */

        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %d", seed);

        if (seed <= 50) {
            console.log("%s is a winner!", msg.sender);
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to send ether from the contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }

    function getWavesByAddress(address _addr) public view returns (uint256) {
        console.log("%s has %d waves!", _addr, wavesMap[_addr]);
        return wavesMap[_addr];
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }
}
