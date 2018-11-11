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
    mapping(string => uint256[]) raToStars;
    mapping(string => uint256[]) decToStars;

    function createStar(string _name, string _ra, string _dec, string _mag, string _story, uint256 _tokenId) public { 
        require(checkIfStarExist(_ra, _dec) == false, "A star with these coordinates is already registered.");

        Star memory newStar = Star(_name, _ra, _dec, _mag, _story);

        tokenIdToStarInfo[_tokenId] = newStar;
        raToStars[_ra].push(_tokenId);
        decToStars[_dec].push(_tokenId);

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
        uint256[] memory ras = raToStars[_ra];
        uint256[] memory decs = decToStars[_dec];

        for(uint i = 0; i < ras.length; i++) {
            for(uint j = 0; j < decs.length; j++) {
                if(ras[i] == decs[j]) {
                    return true;
                }
            }
        }

        return false;
    }
}