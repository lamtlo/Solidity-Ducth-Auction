// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Using our own SimpleToken
import "./SimpleToken.sol";

// Main contract
contract DutchAuction {
    uint256 public immutable startTime;
    uint256 public immutable endTime;
    uint256 public immutable startPrice;

    address payable public immutable seller;
    SimpleToken public immutable token;

    // Make sure that discountRate is integer because solidity does not support float
    uint256 public immutable discountRate;

    // Contract Tx
    constructor(
        uint256 _startPrice,
        uint256 _discountRate,
        uint256 _duration,
        address _token
    ) {
        require(
            _startPrice >= _discountRate * _duration * 1 days,
            "Negative price before expiration."
        );
        seller = payable(msg.sender);
        startPrice = _startPrice;
        startTime = block.timestamp;
        endTime = block.timestamp + _duration * 1 days;

        token = SimpleToken(_token);
        discountRate = _discountRate;
    }

    // Contract call
    function getTokenValue() public view returns (uint256) {
        return token.allowance(seller, address(this));
    }

    // Contract call
    function getUpdatedPrice() public view returns (uint256) {
        return startPrice - (discountRate * (block.timestamp - startTime));
    }

    // Contract Tx
    function bid() external payable {
        require(block.timestamp <= endTime, "Auction already ended.");
        require(msg.value >= getUpdatedPrice(), "Not enough Ether provided.");

        // Contract Tx
        token.transferFrom(seller, msg.sender, getTokenValue());

        if (msg.value - getUpdatedPrice() > 0) {
            payable(msg.sender).transfer(msg.value - getUpdatedPrice());
        }

        selfdestruct(seller);
    }
}
