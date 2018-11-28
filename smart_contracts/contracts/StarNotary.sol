pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 { 

    struct Star { 
        string name; 
        string rightAscension;
        string declination;
        string magnitude;
        string story;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo; 
    mapping(uint256 => uint256) public starsForSale;
    mapping(string => uint256) coordToStar;

    function createStar(string _name, string _ra, string _dec, string _mag, string _story, uint256 _tokenId) public { 
        require(checkIfStarExist(_ra, _dec) == false, "A star with these coordinates is already registered.");

        Star memory newStar = Star(_name, _ra, _dec, _mag, _story);

        tokenIdToStarInfo[_tokenId] = newStar;
        string memory key = coordsToKey(_ra, _dec);
        coordToStar[key] = _tokenId;

        _mint(msg.sender, _tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public { 
        require(this.ownerOf(_tokenId) == msg.sender, "Caller is not the star owner.");

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable { 
        require(starsForSale[_tokenId] > 0, "Star is not for sale.");
        
        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);
        require(msg.value >= starCost, "Payment amount is not sufficient.");

        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);
        
        starOwner.transfer(starCost);

        if(msg.value > starCost) { 
            msg.sender.transfer(msg.value - starCost);
        }
    }

    function checkIfStarExist(string _ra, string _dec) private view returns(bool) {
        string memory key = coordsToKey(_ra, _dec);
        uint256 starId = coordToStar[key];
        return starId != 0;
    }

    function coordsToKey(string _ra, string _dec) private pure returns(string) {
        bytes memory keyBytes = abi.encodePacked(_ra, _dec);
        string memory key = string(keyBytes);
        return key;
    }
}