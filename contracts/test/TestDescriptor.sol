// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.21.0;

import { INounsSeeder } from 'https://raw.githubusercontent.com/nounsDAO/nouns-monorepo/refs/heads/master/packages/nouns-contracts/contracts/interfaces/INounsSeeder.sol'; 
import { INounsDescriptor } from 'https://raw.githubusercontent.com/nounsDAO/nouns-monorepo/refs/heads/master/packages/nouns-contracts/contracts/interfaces/INounsDescriptor.sol';
import { INounsDescriptorMinimal } from 'https://raw.githubusercontent.com/nounsDAO/nouns-monorepo/refs/heads/master/packages/nouns-contracts/contracts/interfaces/INounsDescriptorMinimal.sol';

contract TestNounsDescriptor is INounsDescriptor
{
    function genericDataURI(
        string calldata name,
        string calldata description,
        INounsSeeder.Seed memory seed
    ) external view returns (string memory){

    }

    function tokenURI(uint256 tokenId, INounsSeeder.Seed memory seed) external view returns (string memory){

    }

    function toggleDataURIEnabled() external{

    }

    function setBaseURI(string calldata baseURI) external{

    }

    function palettes(uint8 paletteIndex, uint256 colorIndex) external view returns (string memory){

    }

    function lockParts() external{

    }

    function isDataURIEnabled() external returns (bool){

    }

    function heads(uint256 index) external view returns (bytes memory){
        
    }

    function headCount() external view returns (uint256){
         return 10;
    }

    function glassesCount() external view returns (uint256){
        return 10;
    }

    function glasses(uint256 index) external view returns (bytes memory){

    }

    function generateSVGImage(INounsSeeder.Seed memory seed) external view returns (string memory){

    }

    function dataURI(uint256 tokenId, INounsSeeder.Seed memory seed) external view returns (string memory){

    }

    function bodyCount() external view returns (uint256){
       return 10;
    }

    function bodies(uint256 index) external view returns (bytes memory){

    }

    function baseURI() external returns (string memory){

    }

    function backgrounds(uint256 index) external view returns (string memory){

    }

    function backgroundCount() external view returns (uint256){
        return 10;
    }

    function arePartsLocked() external returns (bool){

    }

    function addManyHeads(bytes[] calldata heads) external{

    }

    function addManyGlasses(bytes[] calldata glasses) external{

    }

    function addManyColorsToPalette(uint8 paletteIndex, string[] calldata newColors) external{

    }

    function addManyBodies(bytes[] calldata bodies) external{

    }

    function addManyBackgrounds(string[] calldata backgrounds) external{

    }

    function addManyAccessories(bytes[] calldata accessories) external
    {

    }

    function addHead(bytes calldata head) external{

    }

    function addGlasses(bytes calldata glasses) external{

    }

    function addColorToPalette(uint8 paletteIndex, string calldata color) external
    {

    }

  function addBody(bytes calldata body) external{

  }

  function accessories(uint256 index) external view returns (bytes memory)
  {

  }

  function accessoryCount() external view returns (uint256)
  {
     return 10;
  }

  function addAccessory(bytes calldata accessory) external{

  }

  function addBackground(string calldata background) external{

  }
}
