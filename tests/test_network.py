from brownie import accounts, deSocial
from brownie.convert import to_bytes, to_string
import pytest

@pytest.fixture
def account():
    return accounts.load('dev')


@pytest.fixture
def account2():
    return accounts.load('dev2')


@pytest.fixture
def network(account):
    return deSocial.deploy({'from': account})


def test_edit_profile(account, network):
    assert network.editProfile("MyUsername", "My Biography", "media-link", {'from': account})
    assert network.userRegistered(account) == True
    assert network.userIndex(network.totalUsers()) == account

    [username, bio, media, followers, following] = network.viewProfile(account)
    assert username == 'myusername'
    assert bio == 'My Biography'
    assert media == 'media-link'


def test_follow_user(account, account2, network):
    assert network.editProfile("MyUsername", "My Biography", "media-link", {'from': account})
    assert network.editProfile("uniqueusername", "My Biography", "media-link", {'from': account2})
    assert network.doesUserFollow(account2, account) is False
    assert network.follow(account, {'from': account2})
    assert network.doesUserFollow(account2, account) is True
    [username, bio, media, followers, following] = network.viewProfile(account)
    assert followers == 1
    [username, bio, media, followers, following] = network.viewProfile(account2)
    assert following == 1


def test_unfollow_user(account, account2, network):
    assert network.editProfile("MyUsername", "My Biography", "media-link", {'from': account})
    assert network.editProfile("uniqueusername", "My Biography", "media-link", {'from': account2})

    assert network.doesUserFollow(account2, account) is False
    assert network.follow(account, {'from': account2})
    assert network.doesUserFollow(account2, account) is True
    assert network.unfollow(account, {'from': account2})
    assert network.doesUserFollow(account2, account) is False

    [username, bio, media, followers, following] = network.viewProfile(account)
    assert followers == 0 and following == 0
    [username, bio, media, followers, following] = network.viewProfile(account2)
    assert following == 0 and followers == 0


def test_update_profile(account, network):
    assert network.editProfile("MyUsername", "My Biography", "media-link", {'from': account})
    assert network.editProfile("owendoteth", "My Biography", "media-link", {'from': account})
    assert network.editProfile("owen", "My Biography", "media-link", {'from': account})