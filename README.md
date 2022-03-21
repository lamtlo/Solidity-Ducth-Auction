# Solidity Dutch Auction (Winner Takes It All)

## How to use

1. The asset to be auctioned in this case is an ERC20 standard token deployed/minted by the seller (in this case a newly created SimpleToken).
2. The seller then initiates a DutchAuction contract with a starting price (Wei), a discount rate by the second (Wei), duration of the auction (days), and the address of the deployed ERC20 token.
3. The seller then needs to approve an amount that the auction contract can send to the winner on his/her behalf.
4. The first bidder who pays more than the current price of the auction before the expiration time will receive the pre-approved amount of token and the changes. At the same time, the seller will receive the paid amount of ETH.

This process will repeat for every item/amount of tokens that any seller wants to put on auction to sell

<br>

## Dependencies

OpenZeppelin/openzeppelin-contracts@4.5.0 - To extend and create our SimpleToken from ERC20 standard

    brownie pm install OpenZeppelin/openzeppelin-contracts@4.5.0

<br>

## Functionalities

- function getTokenValue() public view returns (uint256) // Contract call

Returns the asset value of this auction (i.e. how many tokens can this contract send to the winner)

- function getUpdatedPrice() public view returns (uint256) // Contract call

Returns the current price of this auction

- function bid() external payable // Contract Tx

Allows bidders to make a bid. If the bid won the asset, transfer tokens to the bidder and ETH to the seller immediately

<br>

## Testing

To run the tests in parallel

    brownie test -n auto

Testing scenarios include
- Deployment testing
  - Test ETH balances and token balances of the seller and the bidder at deployment
  - Test the allowance/approve functionality of token (for step 3 in How to use)
  - Test the requirements for Dutch auction contract deployment 
- Auction functionality testing
  - Test the updating price by second functionality
  - Test the ETH transfer from the winner to the seller in case of winning auction
  - Test the token transfer from the seller to the winner in case of winning bid
  - Test the requirements for making a valid bid
