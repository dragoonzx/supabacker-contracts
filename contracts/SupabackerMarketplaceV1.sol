// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract SupabackerMarketplaceV1 is ERC721, ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    Counters.Counter private _tokenIdCounter;

    Project[] private allProjects;

    constructor() ERC721("SupabackerArtifact", "SUPART") { }

    struct Project {
        uint balance;
        string cid;
        EnumerableMap.AddressToUintMap backersDeposits;
    }

    function createProject(string memory uri) public {
        require(bytes(uri).length != 0, "SB: EMPTY STR");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        Project storage newProj = allProjects.push();
        newProj.cid = uri;
    }

    function donateToProject(uint projectId) public payable {
        require(msg.value > 0, "SB: ZERO VALUE");
        allProjects[projectId].balance += msg.value;

        (, uint oldAmount) = allProjects[projectId].backersDeposits.tryGet(msg.sender);
        allProjects[projectId].backersDeposits.set(msg.sender, oldAmount + msg.value);
    }

    function withdrawFunds(uint projectId) public {
        require(ownerOf(projectId) == msg.sender, "SB: NOT OWNER");

        uint amount = allProjects[projectId].balance;
        allProjects[projectId].balance = 0;

        (payable(msg.sender)).transfer(amount);
    }

    function getProjectBalance(uint projectId) public view returns(uint) {
        return allProjects[projectId].balance;
    }

    function getProjectsCount() public view returns(uint) {
        return allProjects.length;
    }

    function getProjectBackersCount(uint projectId) public view returns (uint) {
        return allProjects[projectId].backersDeposits.length();
    }

    function getProjectBackerByIndex(uint projectId, uint index) public view returns (address, uint) {
        return allProjects[projectId].backersDeposits.at(index);
    }

    function getAllBackersOfProject(uint projectId) public view returns (address[] memory addresses, uint[] memory amounts) {
        uint length = getProjectBackersCount(projectId);
        addresses = new address[](length);
        amounts = new uint[](length);

        for (uint256 i = 0; i < length; i++) {
            (addresses[i], amounts[i]) = getProjectBackerByIndex(projectId, i);
        }
    }

    function getProjectUrls() public view returns (string[] memory urls) {
        uint length = allProjects.length;
        urls = new string[](length);
        for (uint256 i = 0; i < length; i++) {
            urls[i] = allProjects[i].cid;
        }
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}