pragma solidity ^0.6.8;
import "OpenZeppelin/openzeppelin-contracts@3.0.0/contracts/token/ERC721/ERC721.sol";
contract deSocial is ERC721('de.Social Account', 'de.Social'){

    struct User {
        bytes username;
        bytes biography;
        bytes ipfsMedia;
        uint256 followerAmount;
        uint256 followingAmount;
    }

    uint256 public totalUsers;
    mapping(address => bool) public userRegistered;
    mapping(uint256 => address) public userIndex;
    mapping(address => User) public userInfo;

    mapping(string => address) public usernameOwner;
    mapping(address => bytes32) public usernameHash;
    mapping(bytes32 => bool) public usernameTaken;

    mapping(address => mapping(address => bool)) public userFollows;
    constructor() public {
        _setBaseURI('api.de.social/profile/');
    }

    function follow(address _user) public {
        require(userRegistered[msg.sender] == true && userRegistered[_user] == true);
        require(_user != msg.sender, "You may not follow yourself");
        userFollows[msg.sender][_user] = true;
        userInfo[msg.sender].followingAmount += 1;
        userInfo[_user].followerAmount += 1;
    }

    function unfollow(address _user) public {
        require(userRegistered[msg.sender] == true && userRegistered[_user] == true);
        require(userFollows[msg.sender][_user] == true, "You do not follow this user");
        userFollows[msg.sender][_user] = false;
        userInfo[msg.sender].followingAmount -= 1;
        userInfo[_user].followerAmount -= 1;
    }

    function editProfile(string memory _username, string memory _biography, string memory _media) public {
        User memory user;
        require(checkString(_username) == true, "Invalid characters or length");
        require(bytes(_biography).length <= 32, "Biography too long");
        bytes32 hashedName = keccak256(abi.encodePacked(lower(_username)));

        if ( userRegistered[msg.sender] == true ) {
            bytes32 currentNameHash = usernameHash[msg.sender];

            if ( hashedName != currentNameHash) {
                require(usernameTaken[hashedName] != true, "Username taken");
                usernameTaken[currentNameHash] = false;
            }

            user = userInfo[msg.sender];
            user.username = bytes(_username);
            user.biography = bytes(_biography);
            user.ipfsMedia = bytes(_media);

        } else {
            require(usernameTaken[hashedName] != true, "Username taken");
            user = User(bytes(_username), bytes(_biography), bytes(_media), 0, 0);
            _mint(msg.sender, totalSupply());
            userIndex[totalSupply()] = msg.sender;
            userRegistered[msg.sender] = true;
        }
        usernameTaken[hashedName] = true;
        usernameOwner[_username] = msg.sender;
        usernameHash[msg.sender] = hashedName;
        userInfo[msg.sender] = user;
    }

    function doesUserFollow(address _user1, address _user2) public view returns(bool) {
        if (userFollows[_user1][_user2]) return true;
        return false;
    }

    function viewProfile(address _user) public view returns(string memory, string memory, string memory, uint256, uint256) {
        User memory user = userInfo[_user];
        return (string(user.username), string(user.biography), string(user.ipfsMedia), user.followerAmount, user.followingAmount);
    }

    function checkString(string memory _s) internal pure returns(bool) {
        bytes memory b = bytes(_s);
        if (b.length > 16 || b.length < 3) return false;
        for (uint i; i<b.length; i++) {
            bytes1 char = b[i];
            if (
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x41 && char <= 0x5A) && //A-Z
                !(char >= 0x61 && char <= 0x7A) && //a-z
                !(char == 0x2E) //.
            )
                return false;
        }
        return true;
    }
    function lower(string memory _base)
        internal
        pure
        returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }
     function _lower(bytes1 _b1)
        private
        pure
        returns (bytes1) {

        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1) + 32);
        }

        return _b1;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(to == msg.sender, "This token is not transferrable!");
    }

}
