from brownie import deSocialNFTBETA, accounts
from brownie.convert import to_bytes, to_string
import pytest

@pytest.fixture
def account():
    return accounts.load('dev')

@pytest.fixture
def nft(account):
    return deSocialNFTBETA.deploy({'from': account})


def test_mint_nft(nft, account):
    assert nft.requestMint("test mint", "ipfs hash", {'from': account})
    assert nft.balanceOf(account) == 1
    [title, ipfs, creator, timestamp, likes, comments] = nft.getMetaData(1)
    assert title == "test mint"
    assert ipfs == "ipfs hash"
    assert likes == 0
    assert comments == 0

def test_comment(nft, account):
    assert nft.requestMint("test mint", "ipfs hash", {'from': account})
    assert nft.comment(1, "this is my comment!", {'from': account})
    assert nft.comment(1, "this is also my comment!", {'from': account})
    [title, ipfs, creator, timestamp, likes, comments] = nft.getMetaData(1)
    assert comments == 2
    for i in range(comments):
        comment = nft.readComment(1, i)
        print(comment)
    assert nft.readComment(1, 0)[1] == "this is my comment!"
    assert nft.readComment(1, 1)[1] == "this is also my comment!"

def test_likes(nft, account):
    assert nft.requestMint("test mint", "ipfs hash", {'from': account})
    assert nft.like(1, {'from': account})
    [title, ipfs, creator, timestamp, likes, comments] = nft.getMetaData(1)
    assert likes == 1
    assert nft.like(1, {'from': account})
    [title, ipfs, creator, timestamp, likes, comments] = nft.getMetaData(1)
    assert likes == 0