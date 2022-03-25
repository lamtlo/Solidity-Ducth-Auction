// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Using our own SimpleToken
import "./SimpleToken.sol";

// Main contract
contract DutchAuction {
    // Declare in this exact order to save some gas
    uint256 public immutable startTime;
    uint256 public immutable endTime;
    uint256 public immutable startPrice;
    uint256 public change;

    // Make sure that discountRate is integer because solidity does not support float
    uint256 public immutable discountRate;

    address payable public immutable seller;
    bool public locked;

    address payable public winner;

    SimpleToken public immutable token;

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
        startPrice = _startPrice;
        discountRate = _discountRate;
        startTime = block.timestamp;
        endTime = block.timestamp + _duration * 1 days;

        seller = payable(msg.sender);

        token = SimpleToken(_token);
    }

    // Contract call
    function getTokenValue() public view returns (uint256) {
        return token.allowance(seller, address(this));
    }

    // Contract call
    function getUpdatedPrice() public view returns (uint256) {
        return startPrice - (discountRate * (block.timestamp - startTime));
    }

    event TokenTransferred(address seller, address bidder, uint256 tokenAmount);
    event Log(string);

    modifier noReentrancy() {
        require(!locked, "No re-entrancy.");

        locked = true;
        _;
        locked = false;
    }

    // Contract Tx
    function bid() external payable noReentrancy {
        require(block.timestamp <= endTime, "Auction already ended.");
        require(msg.value >= getUpdatedPrice(), "Not enough ETH provided.");

        winner = payable(msg.sender);
        change = msg.value - getUpdatedPrice();

        // Contract Tx
        try token.transferFrom(seller, msg.sender, getTokenValue()) {
            emit TokenTransferred(seller, msg.sender, getTokenValue());
        } catch Error(string memory reason) {
            emit Log(reason);
        }

        if (change == 0) {
            selfdestruct(seller);
        } else {
            (bool sent, bytes memory data) = seller.call{
                value: msg.value - change
            }("");
            require(sent, "Failed to send ETH to seller.");
        }
    }

    function withdrawChange() external {
        require(
            msg.sender == winner,
            "Only winner is allowed to withdraw channge."
        );
        require(change > 0, "There's no change to withdraw.");

        (bool sent, bytes memory data) = payable(msg.sender).call{
            value: change
        }("");

        require(sent, "Failed to send ETH to winner.");
    }
}
