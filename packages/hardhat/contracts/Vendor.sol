pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Vendor is Ownable, ReentrancyGuard {
	uint256 public constant tokensPerEth = 100;
	event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event SellTokens(
		address seller,
		uint256 amountOfTokens,
		uint256 amountOfETH
	);
	YourToken public yourToken;

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// ToDo: create a payable buyTokens() function:
	function buyTokens() external payable nonReentrant {
		yourToken.transfer(msg.sender, msg.value * tokensPerEth);
		address(this).call{ value: msg.value }("");
		emit BuyTokens(msg.sender, msg.value, msg.value * tokensPerEth);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH
	function withdraw() public payable onlyOwner nonReentrant {
		payable(msg.sender).call{ value: address(this).balance }("");
	}

	// ToDo: create a sellTokens(uint256 _amount) function:
	function sellTokens(uint256 _amount) external payable {
		yourToken.transferFrom(msg.sender, address(this), _amount);
		payable(msg.sender).call{ value: _amount / tokensPerEth }("");
		emit BuyTokens(msg.sender, _amount, _amount / tokensPerEth);
	}

	receive() external payable {}
}
