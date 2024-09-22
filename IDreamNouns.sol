// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.21.0;

import { INounsSeeder } from 'https://raw.githubusercontent.com/nounsDAO/nouns-monorepo/refs/heads/master/packages/nouns-contracts/contracts/interfaces/INounsSeeder.sol'; 

interface IDreamNouns
{
    struct DreamNoun 
    {
        uint48  Background;
        bool IncludeBackground;
        uint48  Body;
        bool IncludeBody;
        uint48  Accessory;
        bool IncludeAccessory;
        uint48  Head;
        bool IncludeHead;
        uint48  Glasses;
        bool IncludeGlasses;
        uint256  Deposit;
        uint256 SpawnedAt;
        address Owner;
    }

    struct DreamNounIndex 
    {
        bool Exists;
        uint256 Index;
    }

    struct DreamNounRequest 
    {
        uint48  Background;
        bool IncludeBackground;
        uint48  Body;
        bool IncludeBody;
        uint48  Accessory;
        bool IncludeAccessory;
        uint48  Head;
        bool IncludeHead;
        uint48  Glasses;
        bool IncludeGlasses;
    }

    struct MatchedDreamNounResponse 
    {
        bool HasMatched;
        uint256 BlockNumber;
        string NounTraitsKey;
        uint256 DreamNounIndex;
        uint48 Background;
        uint48 Body;
        uint48 Accessory;
        uint48 Head;
        uint48 Glasses;
    }

    event DreamNounQueued(uint256 indexed dreamNounIndex, address indexed sender, uint256 depositPaid,  uint256 timestamp);
    event DreamNounSpawned(uint256 indexed dreamNounIndex, uint256 blockNumber, address indexed owner, string indexed nounSeedKey, uint256 timestamp);
    event MinimumDepositUpdated(uint256 oldMinimumDeposit, uint256 newMinimumDeposit, address indexed sender, uint256 timestamp);
    event NounsAuctionHouseUpdated(address indexed oldNounsAuctionHouseAddress, address indexed newNounsAuctionHouseAddress, uint256 timestamp);
    event NounsDescriptorMinimalUpdated(address indexed oldNounsDescriptorMinimalAddress, address indexed newNounsDescriptorMinimalAddress, uint256 timestamp);
    event SpawnManagerUpdated(address indexed oldSpawnManagerAddress, address indexed newSpawnManagerAddress, uint256 timestamp);
    event SpawnManagerSentDeposit(address indexed fromAddress, address indexed spawnManagerAddress, uint256 amount, uint256 timestamp);

    function addDreamNoun(DreamNounRequest memory nounDefinition) payable external;
    function spawnDreamNoun(uint256 blockNumber, string memory nounTraitsKey) external;
    function setMinimumDeposit(uint256 minimumDeposit) external;
    function getNounTraitsKey(bool includeBackground, uint48 background, bool includeBody, uint48 body, bool includeAccessory, uint48 accessory, bool includeHead, uint48 head, bool includeGlasses, uint48 glasses) external pure returns(string memory);
    function getSeedForCurrentBlock() external view returns(INounsSeeder.Seed memory seed);
    function getDreamNounMatch() external view returns(MatchedDreamNounResponse memory matchedDreamNounResponse);
    function getDreamProbability(DreamNounRequest memory nounDefinition) external view returns(uint256);
    function isDreamNounQueued(DreamNoun memory dreamNoun) external view returns(bool);
    function isNounOClock() external view returns(bool);
    function getTotalDreamNouns() external view returns(uint256);
    function getUsersTotalDreamNouns(address user) external view returns(uint256);
}
