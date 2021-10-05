from brownie import deSocial, deSocialNFTBETA, accounts
from brownie.network.gas.strategies import GasNowStrategy
gas_strategy = GasNowStrategy("fast")
def main():
    dev = accounts.load('poly')
    nft = deSocialNFTBETA.at('0x8E3FB61AF20BE85bbB41c71Bce620A4c11F42bC7')
    nft.requestMint('polygon is shit', 'QmSirZFKLwFAhCGAURWiQNSxYKxhct4JHMnw1ABDi5HUsJ', {'from': dev, 'gas_price': gas_strategy})
    # QmSirZFKLwFAhCGAURWiQNSxYKxhct4JHMnw1ABDi5HUsJ
    # social.editProfile('LarryDavid', "NFT Enthusiast",'QmNccSguWo96vxC9fkaZMV1LJzkb2hXrB7tzqSWVf38hRc', {'from': dev})

