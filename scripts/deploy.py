# This script is not finished as prerequisites to deploy are not met
from traceback import print_tb
from brownie import accounts, SimpleToken, DutchAuction

def main():
    acct = accounts.load("deployment_account")
    token = SimpleToken.deploy({"from": acct})
    auction = DutchAuction.deploy(1e9, 1000, token.address, {"from": acct})
    token.approve(auction.address, 5, {"from": acct})
    return auction
