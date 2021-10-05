pragma solidity ^0.6.6;

import "OpenZeppelin/openzeppelin-contracts@3.0.0/contracts/token/ERC721/ERC721.sol";
import "OpenZeppelin/openzeppelin-contracts@3.0.0/contracts/token/ERC721/ERC721Burnable.sol";


/*This contract allows users of the NFT app to mint their own ERC-721 NFTs via de.Social mobile app*/
contract deSocialNFTBETA is ERC721("de.Social NFT", "DE.SOCIAL NFT"), ERC721Burnable {

    struct Media {
        string title;
        string ipfs;
        address creator;
        uint256 timestamp;
        uint256 likes;
        uint256 comments;
    }

    struct Comment {
        address sender;
        bytes message;
    }

    mapping(uint256 => Media) tokenIndex;
    mapping(uint256 => Comment[]) tokenComments;
    mapping(uint256 => mapping(address => bool)) public userHasLiked;

    constructor() public {
        _setBaseURI("api.de.social/token/");
    }

    function requestMint(string memory _title, string memory _ipfs) public  {
        Media memory _media = Media(_title, _ipfs, msg.sender, block.timestamp, 0, 0);
        tokenIndex[totalSupply() + 1] = _media;
        _safeMint(_media.creator, totalSupply() + 1);
    }

    function like(uint256 _id) public {

        if (userHasLiked[_id][msg.sender] == true) {
            tokenIndex[_id].likes -= 1;
            userHasLiked[_id][msg.sender] = false;
        }
        else {
            tokenIndex[_id].likes += 1;
            userHasLiked[_id][msg.sender] = true;
        }
    }

    function comment(uint256 _id, string memory _message) public {
        Comment memory comment = Comment(msg.sender, bytes(_message));
        tokenIndex[_id].comments += 1;
        tokenComments[_id].push(comment);
    }

    function readComment(uint256 _id, uint256 _commentIndex) public view returns (address, string memory) {
        Comment memory comment = tokenComments[_id][_commentIndex];
        return (comment.sender, string(comment.message));
    }

    function getMetaData(uint256 _id) public view returns(string memory, string memory, address, uint256, uint256, uint256) {
        Media memory _media = tokenIndex[_id];
        return (_media.title, _media.ipfs, _media.creator, _media.timestamp, _media.likes, _media.comments);
    }

    function userLiked(uint256 _id, address _user) public view returns (bool) {
        if (userHasLiked[_id][_user] == true) {
            return true;
        }
        return false;
    }

}