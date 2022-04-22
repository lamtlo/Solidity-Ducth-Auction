import pytest
import brownie
from brownie import chain
from random import randint


def test_start_price(auction):
    assert auction.startPrice() == 1e9


def test_update_price(auction):
    discountRate = auction.discountRate()
    duration = randint(0, auction.endTime() - auction.startTime())
    initial_price = auction.getUpdatedPrice()

    chain.sleep(duration)
    chain.mine()
    new_price = auction.getUpdatedPrice()

    # Test that the updated price is in a range of values to account for marginal error. The getUpdatedPrice() function mighr be call upto 5 seconds later block is mined
    assert new_price in range(
        initial_price - discountRate * duration,
        initial_price - discountRate * (duration + 5),
        -discountRate
    )


def test_bid_transfer_eth(auction, seller, bidder):
    discountRate = auction.discountRate()
    balance_before_seller = seller.balance()
    balance_before_bidder = bidder.balance()
    duration = randint(0, auction.endTime() - auction.startTime())

    chain.sleep(duration)
    chain.mine()
    current_price = auction.getUpdatedPrice()
    auction.bid({"from": bidder, "value": 1e9 + 1234})

    auction.withdrawChange({"from": bidder})
    # Seller might receive and bidder might pay a little less eth due to marginal error of the update price
    assert seller.balance() in range(
        balance_before_seller + current_price,
        balance_before_seller + current_price - discountRate * 5,
        -discountRate
    )
    assert bidder.balance() in range(
        balance_before_bidder - current_price,
        balance_before_seller - current_price + discountRate * 5,
        discountRate
    )


def test_bid_transfer_token(token, auction, seller, bidder):
    token_balance_seller = token.balanceOf(seller)
    token_balance_bidder = token.balanceOf(bidder)
    duration = randint(0, auction.endTime() - auction.startTime())
    asset = auction.getTokenValue()

    assert token.balanceOf(auction.address) == 0
    assert token.balanceOf(bidder) == 0

    chain.sleep(duration)
    auction.bid({"from": bidder, "value": 1e9 + 1000})

    assert token.balanceOf(auction.address) == 0
    assert token.balanceOf(seller) == token_balance_seller - asset
    assert token.balanceOf(bidder) == token_balance_bidder + asset


def test_insufficient_eth(token, auction, seller, bidder):
    balance_before_seller = seller.balance()
    balance_before_bidder = bidder.balance()
    token_balance_seller = token.balanceOf(seller)
    token_balance_bidder = token.balanceOf(bidder)

    with brownie.reverts("Not enough ETH provided."):
        auction.bid({"from": bidder, "value": 9000})

    assert seller.balance() == balance_before_seller
    assert bidder.balance() == balance_before_bidder
    assert token.balanceOf(seller) == token_balance_seller
    assert token.balanceOf(bidder) == token_balance_bidder


def test_contract_expired(token, auction, seller, bidder):
    balance_before_seller = seller.balance()
    balance_before_bidder = bidder.balance()
    token_balance_seller = token.balanceOf(seller)
    token_balance_bidder = token.balanceOf(bidder)

    chain.sleep(auction.endTime() - auction.startTime() + 10)
    with brownie.reverts("Auction already ended."):
        auction.bid({"from": bidder, "value": 9000})

    assert seller.balance() == balance_before_seller
    assert bidder.balance() == balance_before_bidder
    assert token.balanceOf(seller) == token_balance_seller
    assert token.balanceOf(bidder) == token_balance_bidder
