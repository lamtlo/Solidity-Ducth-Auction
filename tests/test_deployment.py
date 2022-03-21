import pytest
import brownie
from brownie import DutchAuction


def test_token_balance(token, auction, seller, bidder):
    assert token.balanceOf(seller) == 10
    assert token.balanceOf(bidder) == 0
    assert token.balanceOf(auction.address) == 0


def test_token_allowance(token, auction, seller, bidder):
    assert token.allowance(seller, seller) == token.balanceOf(seller)
    assert token.allowance(seller, auction.address) == 5
    assert auction.getTokenValue() == 5


def test_transfer(token, seller, bidder):
    token.transferFrom(seller, bidder, 5, {"from": seller})
    assert token.balanceOf(seller) == 5
    assert token.balanceOf(bidder) == 5


def test_account_balance(seller, bidder):
    balance_seller = seller.balance()
    balance_bidder = bidder.balance()
    seller.transfer(bidder, "10 ether")
    assert seller.balance() == balance_seller - "10 ether"
    assert bidder.balance() == balance_bidder + "10 ether"


def test_invalid_auction(token, seller):
    invalid_auction = False
    with brownie.reverts("Negative price before expiration."):
        invalid_auction = DutchAuction.deploy(
            1e9, 1e4, 10, token.address, {"from": seller}
        )
    assert invalid_auction == False
