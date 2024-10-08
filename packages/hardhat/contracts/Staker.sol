// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staker is ReentrancyGuard {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 seconds;
  bool public openForWithdraw = false;

  
  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
  function stake() public payable{
    require(deadline >= block.timestamp, "deadline has met already");
    balances[msg.sender] += msg.value;
    // send the eth from msg.sender to the contract
    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() public nonReentrant notCompleted{
    require(deadline < block.timestamp, "deadline not met yet");
    if(address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }else{
      openForWithdraw = true;
    }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public nonReentrant notCompleted {
    require(openForWithdraw, "not open for withdrawal yet");
    uint256 amount = balances[msg.sender];
    msg.sender.call{value: amount}("");
    balances[msg.sender] = 0;
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft()public view returns (uint256){
    return block.timestamp >= deadline? 0 : deadline - block.timestamp;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    require(deadline >= block.timestamp, "deadline has met already");

    stake();
  }

  event Stake(address userAddress,uint256 val);

  modifier notCompleted() {
      require(!exampleExternalContract.completed(), "Action not allowed: contract is completed");
      _;
  }

}
