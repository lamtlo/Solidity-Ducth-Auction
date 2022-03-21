import pytest
from brownie import SimpleToken, DutchAuction, accounts


@pytest.fixture(scope="module", autouse=True)
def seller(module_isolation):
    return accounts[0]


@pytest.fixture(scope="module", autouse=True)
def bidder(module_isolation):
    return accounts[1]


@pytest.fixture(scope="function", autouse=True)
def token(seller, fn_isolation):
    return SimpleToken.deploy({"from": seller})


@pytest.fixture(scope="function", autouse=True)
def auction(token, seller, fn_isolation):
    auction = DutchAuction.deploy(1e9, 1000, 10, token.address, {"from": seller})
    token.approve(
        auction.address, 5, {"from": seller}
    )  # Put out 5 SimpleToken for auction
    return auction
