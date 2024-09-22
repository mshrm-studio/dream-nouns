// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.21.0;

import { IERC721Enumerable } from '@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol';

contract TestNounToken is IERC721Enumerable
{
    function transferFrom(address from, address to, uint256 tokenId) external{

    }
    
    function totalSupply() external view returns (uint256){
       return 12;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256){

    }

    function tokenByIndex(uint256 index) external view returns (uint256){

    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool){

    }

    function setApprovalForAll(address operator, bool approved) external{

    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external{

    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external{

    }

    function approve(address to, uint256 tokenId) external{

    }

    function balanceOf(address owner) external view returns (uint256 balance){

    }

    function getApproved(uint256 tokenId) external view returns (address operator){

    }
    function isApprovedForAll(address owner, address operator) external view returns (bool){

    }

    function ownerOf(uint256 tokenId) external view returns (address owner){

    }

}
