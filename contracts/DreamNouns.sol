// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.21.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import { IDreamNouns } from "./IDreamNouns.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC721Enumerable } from '@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol';
import { INounsAuctionHouseV2 } from 'https://raw.githubusercontent.com/nounsDAO/nouns-monorepo/refs/heads/master/packages/nouns-contracts/contracts/interfaces/INounsAuctionHouseV2.sol';
import { INounsDescriptorMinimal } from 'https://raw.githubusercontent.com/nounsDAO/nouns-monorepo/refs/heads/master/packages/nouns-contracts/contracts/interfaces/INounsDescriptorMinimal.sol';
import { INounsSeeder } from 'https://raw.githubusercontent.com/nounsDAO/nouns-monorepo/refs/heads/master/packages/nouns-contracts/contracts/interfaces/INounsSeeder.sol'; 
import { INounsToken } from 'https://raw.githubusercontent.com/nounsDAO/nouns-monorepo/refs/heads/master/packages/nouns-contracts/contracts/interfaces/INounsToken.sol';

contract DreamNouns is IDreamNouns, AccessControl, Ownable, ReentrancyGuard 
{
    // All dream nouns in existance
    DreamNoun[] public _dreamNouns;

    // Users dream nouns
    mapping(address => uint256[]) public _userDreamNounIndexes;

    // A string key to dream noun mapping
    mapping(string => DreamNounIndex) public _traitKeyToNounIndexes;

    // The minimum cost for adding a dream noun
    uint256 private _minimumDeposit = 100000;

    // A list of all possible selection permutations (include head, include body etc.) of dream nouns
    bool[][] private _selectionPermutations;

    // Nouns auction contract - to settle dream noun on
    INounsAuctionHouseV2 private _nounsAuctionHouse;

    // Nouns descriptor contract - to get 
    INounsDescriptorMinimal private _nounsDescriptorMinimal;

    // Nouns token contract
    IERC721Enumerable immutable private _enumerableNounsToken;

    // Nouns seeder contract
    INounsSeeder immutable private _nounsSeeder;

    // Address that will be doing the spawning of a new noun if matched (caller for spawnDreamNoun)
    address payable public _spawnManager;

    // A role for a user to be able to update minimum deposit
    bytes32 public constant UPDATE_MINIMUM_DEPOSIT_AMOUNT_ROLE = keccak256("MINIMUM_DEPOSIT_AMOUNT_ROLE");

    constructor(
        INounsDescriptorMinimal nounsDescriptor, 
        IERC721Enumerable nounToken, 
        INounsSeeder nounsSeeder,
        INounsAuctionHouseV2 nounsAuctionHouse,
        address payable spawnManager,
        address nounsDaoOwnerAddress
    )
    { 
        // Set contracts
        _nounsAuctionHouse = nounsAuctionHouse;
        _nounsDescriptorMinimal = nounsDescriptor;
        _enumerableNounsToken = nounToken;
        _nounsSeeder = nounsSeeder;

        // Set spawn manager
        _spawnManager = spawnManager;

        // Setup roles
        _setupRoles(_spawnManager, nounsDaoOwnerAddress);
    }

    function addDreamNoun(
        DreamNounRequest memory dreamNounRequest
    ) payable external
    {
        // Check the amount sent is over the minimum required
        require(msg.value >= _minimumDeposit, 'The minimum deposit has not been met');

        // Also check that the attributes are within bounds
        bool validated = _validateParts(dreamNounRequest);
        require(validated == true, 'Noun part out of bounds');
        
        // Turn to dream noun
        DreamNoun memory dreamNoun = DreamNoun(
            dreamNounRequest.Background,
            dreamNounRequest.IncludeBackground,
            dreamNounRequest.Body,
            dreamNounRequest.IncludeBody,
            dreamNounRequest.Accessory,
            dreamNounRequest.IncludeAccessory,
            dreamNounRequest.Head,
            dreamNounRequest.IncludeHead,
            dreamNounRequest.Glasses,
            dreamNounRequest.IncludeGlasses,
            msg.value,
            0,
            msg.sender
        );

        // Create key
        string memory nounsTraitsKey = getNounTraitsKey(
            dreamNounRequest.IncludeBackground,
            dreamNounRequest.Background,
            dreamNounRequest.IncludeBody,
            dreamNounRequest.Body,
            dreamNounRequest.IncludeAccessory,
            dreamNounRequest.Accessory,
            dreamNounRequest.IncludeHead,
            dreamNounRequest.Head,
            dreamNounRequest.IncludeGlasses,
            dreamNounRequest.Glasses
        );
//[0,false,0,false,0,false,0,false,1,true]
        // Get the index for the key
        DreamNounIndex storage existingDreamNounIndex = _traitKeyToNounIndexes[nounsTraitsKey];

        // Check if someone already is waiting for the same dream noun 
        require(existingDreamNounIndex.Exists == false, 'Another user is already waiting for the same dream noun');

        // Send funds to the spawn manager & fire event
        //_moveFundsToSpawnManager(msg.value);

        // Save dream noun
        _dreamNouns.push(dreamNoun);
        
        // Update the indexed value and make it available for match
        uint256 newNounIndex = _dreamNouns.length - 1;
        existingDreamNounIndex.Index = newNounIndex;
        existingDreamNounIndex.Exists = true;
        
        // Add an index to the new dream added to a user
        uint256[] storage indexes =_userDreamNounIndexes[msg.sender];
        indexes.push(newNounIndex);

        // Fire event logging the new dream noun added
        emit DreamNounQueued(newNounIndex, msg.sender, msg.value, block.timestamp);
    } 

    function spawnDreamNoun(
        uint256 blockNumber, 
        string memory nounTraitsKey
    ) external
    {
        // Ensure block is same as matched request
        require(block.number == blockNumber, 'Block number doesnt match');

        // Ensure the current match is the same traits key
        MatchedDreamNounResponse memory matchedDreamNounResponse = getDreamNounMatch();
        require(Strings.equal(matchedDreamNounResponse.NounTraitsKey, nounTraitsKey), 'Traits key does not match');

        // Ensure we can mint (is noun oclock)
        //require(isNounOClock(), 'Cannot settle if auction has not ended');

        // Get the nouns index from matched key & check it exists
        DreamNounIndex storage index = _traitKeyToNounIndexes[nounTraitsKey];
        require(index.Exists, 'Index doesnt exist');

        // Mark it so it can no longer be matched
        index.Exists = false;

        // Get the noun & mark spawned
        DreamNoun storage dreamNoun = _dreamNouns[index.Index];
        dreamNoun.SpawnedAt = block.timestamp;

        // Settle noun
        _nounsAuctionHouse.settleCurrentAndCreateNewAuction();     

        // Emit event
        emit DreamNounSpawned(index.Index, block.number, dreamNoun.Owner, nounTraitsKey, block.timestamp);
    }

    function getDreamNounMatch() public view returns(MatchedDreamNounResponse memory matchedDreamNounResponse)
    {
        INounsSeeder.Seed memory seed = getSeedForCurrentBlock();

        for(uint256 i=0; i < _selectionPermutations.length; i++)
        {
            bool[] memory partDefinition = _selectionPermutations[i];

            string memory nounTraitsKey = getNounTraitsKey(
                partDefinition[0], 
                seed.background, 
                partDefinition[1],
                seed.body,
                partDefinition[2],
                seed.accessory,
                partDefinition[3],
                seed.head,
                partDefinition[4],
                seed.glasses
            );

            DreamNounIndex storage index = _traitKeyToNounIndexes[nounTraitsKey];
            if(index.Exists)
            {
                // Then we have a match...
                matchedDreamNounResponse.HasMatched = true;
                matchedDreamNounResponse.BlockNumber = block.number;
                matchedDreamNounResponse.NounTraitsKey = nounTraitsKey;
                matchedDreamNounResponse.DreamNounIndex = index.Index;
                matchedDreamNounResponse.Body = seed.body;
                matchedDreamNounResponse.Head = seed.head;
                matchedDreamNounResponse.Background = seed.background;
                matchedDreamNounResponse.Glasses = seed.glasses;
                matchedDreamNounResponse.Accessory = seed.accessory;
    
                return matchedDreamNounResponse;
            }
        }
    }

    function getNounTraitsKey(
        bool includeBackground, 
        uint48 background,
        bool includeBody, 
        uint48 body,
        bool includeAccessory, 
        uint48 accessory,
        bool includeHead, 
        uint48 head,
        bool includeGlasses, 
        uint48 glasses
    ) public pure returns(string memory)
    {
        return string(abi.encodePacked(
            includeBackground ? Strings.toString(background) : 'x',
            '-',
            includeBody ? Strings.toString(body) : 'x',
            '-',
            includeAccessory ? Strings.toString(accessory) : 'x',
            '-',
            includeHead ? Strings.toString(head) : 'x',
            '-',
            includeGlasses ? Strings.toString(glasses) : 'x'
        ));
    }

    function getSeedForCurrentBlock() public view returns(INounsSeeder.Seed memory seed)
    {
        uint256 currentNounId = _enumerableNounsToken.totalSupply() - 1;

        return _nounsSeeder.generateSeed(currentNounId, _nounsDescriptorMinimal);
    }

    function getDreamProbability(
        DreamNounRequest memory nounDefinition
    ) external view returns(uint256)
    {
        uint256 denominator = 0;

        if(nounDefinition.IncludeBackground)
        {
            denominator *= _nounsDescriptorMinimal.backgroundCount();
        }

        if(nounDefinition.IncludeBody)
        {
            denominator *= _nounsDescriptorMinimal.bodyCount();
        }

        if(nounDefinition.IncludeAccessory)
        {
            denominator *= _nounsDescriptorMinimal.accessoryCount();
        }

        if(nounDefinition.IncludeHead)
        {
            denominator *= _nounsDescriptorMinimal.headCount();
        }

        if(nounDefinition.IncludeGlasses)
        {
            denominator *= _nounsDescriptorMinimal.glassesCount();
        }

        return denominator;
    }

    function getTotalDreamNouns() public view returns(uint256)
    {
        return _dreamNouns.length;
    }

    function getUsersTotalDreamNouns(
        address user
    ) public view returns(uint256)
    {
        return _userDreamNounIndexes[user].length;
    }

    function isDreamNounQueued(
        DreamNoun memory dreamNoun
    ) public view returns(bool)
    {
        string memory nounTraitsKey = getNounTraitsKey(
            dreamNoun.IncludeBackground,
            dreamNoun.Background,
            dreamNoun.IncludeBody,
            dreamNoun.Body,
            dreamNoun.IncludeAccessory,
            dreamNoun.Accessory,
            dreamNoun.IncludeHead,
            dreamNoun.Head,
            dreamNoun.IncludeGlasses,
            dreamNoun.Glasses
        );

        DreamNounIndex storage index = _traitKeyToNounIndexes[nounTraitsKey];

        return index.Exists;
    }

    function isNounOClock() public view returns(bool)
    {
        // Get the current auction
        INounsAuctionHouseV2.AuctionV2View memory auction = _nounsAuctionHouse.auction();

        // Check its ended, if so return true
        if(auction.endTime <= block.timestamp)
        {
            return true;
        }

        return false;
    }

    function setMinimumDeposit(
        uint256 minimumDeposit
    ) external 
    {
        // Check that the calling account has the minimum deposit role
        require(hasRole(UPDATE_MINIMUM_DEPOSIT_AMOUNT_ROLE, msg.sender), 'Update minimum deposit role not found');

        // Keep old one for event
        uint256 oldMinimum = _minimumDeposit;

        // Set to new one
        _minimumDeposit = minimumDeposit;

        // Fire event for it
        emit MinimumDepositUpdated(oldMinimum, _minimumDeposit, msg.sender, block.timestamp);
    }

    function setNounsAuctionHouse(
        INounsAuctionHouseV2 nounsAuctionHouse
    ) external onlyOwner
    {
        // Get the old and new address for logging
        address oldNounsAuctionHouseAddress = address(_nounsAuctionHouse);
        address newNounsAuctionHouseAddress = address(nounsAuctionHouse);

        // Set new auction house
        _nounsAuctionHouse = nounsAuctionHouse;

        // Fire event logging old & new values
        emit NounsAuctionHouseUpdated(oldNounsAuctionHouseAddress, newNounsAuctionHouseAddress, block.timestamp);
    }

    function setNounsMinimalDescriptor(
        INounsDescriptorMinimal nounsDescriptorMinimal
    ) external onlyOwner
    {
        // Get the old and new address for logging
        address oldNounsDescriptorMinimalAddress = address(_nounsDescriptorMinimal);
        address newNounsDescriptorMinimalAddress = address(nounsDescriptorMinimal);

        // Set new nouns descriptor
        _nounsDescriptorMinimal = nounsDescriptorMinimal;

        // Fire event logging old & new values
        emit NounsDescriptorMinimalUpdated(oldNounsDescriptorMinimalAddress, newNounsDescriptorMinimalAddress, block.timestamp);
    }

    function setSpawnManager(
        address payable spawnManager
    ) external onlyOwner
    {
        // Remove old spawn manager from role
        _revokeRole(UPDATE_MINIMUM_DEPOSIT_AMOUNT_ROLE, _spawnManager);

        // Get the old and new address for logging
        address oldSpawnManagerAddress = _spawnManager;
        
        // Set new spawn manager address
        _spawnManager = spawnManager;

        // Add role to new spawn manager
        _grantRole(UPDATE_MINIMUM_DEPOSIT_AMOUNT_ROLE, _spawnManager);
 
        // Fire event logging old & new values
        emit SpawnManagerUpdated(oldSpawnManagerAddress, _spawnManager, block.timestamp);
    }

    function _moveFundsToSpawnManager(
        uint256 amount
    ) internal 
    {
        // Transfer amount to the spawn manager address
        _spawnManager.transfer(amount);

        // Fire loggin event for this transfer
        emit SpawnManagerSentDeposit(msg.sender, _spawnManager, msg.value, block.timestamp);
    }

    function _setupRoles(
        address spawnManagerAddress, 
        address nounsDaoOwnerAddress
    ) internal
    {
        // Role to allow minium deposit updates
        _grantRole(UPDATE_MINIMUM_DEPOSIT_AMOUNT_ROLE, spawnManagerAddress);
        _grantRole(UPDATE_MINIMUM_DEPOSIT_AMOUNT_ROLE, nounsDaoOwnerAddress);

        // Add owner rights to grant any roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function populateSelectionPermutations() public 
    {
        // Ensure only populated once
        require(_selectionPermutations.length == 0, 'Already populated');

        // Note (traints:indexes): Background:0, Body:1, Accessory:2, Head:3, Glasses:4
        // Note (Least to best prefernced) : 5. background 4. body 3. accessory 2. glasses 1. head

        // All 5 matches
        _selectionPermutations.push([true,true,true,true,true]);
 
        // 4 matches
        _selectionPermutations.push([false,true,true,true,true]);
        _selectionPermutations.push([true,false,true,true,true]);
        _selectionPermutations.push([true,true,false,true,true]);
        _selectionPermutations.push([true,true,true,true,false]);
        _selectionPermutations.push([true,true,true,false,true]);

        // 3 matches
        _selectionPermutations.push([false,false,true,true,true]);
        _selectionPermutations.push([false,true,false,true,true]);
        _selectionPermutations.push([false,true,true,true,false]);
        _selectionPermutations.push([false,true,true,false,true]);
        _selectionPermutations.push([true,false,false,true,true]);
        _selectionPermutations.push([true,false,true,true,false]);
        _selectionPermutations.push([true,false,true,false,true]);
        _selectionPermutations.push([true,true,false,true,false]);
        _selectionPermutations.push([true,true,false,false,true]);
        _selectionPermutations.push([true,true,true,false,false]);

        // 2 matches
        _selectionPermutations.push([false,false,false,true,true]);
        _selectionPermutations.push([false,false,true,true,false]);
        _selectionPermutations.push([false,false,true,false,true]);
        _selectionPermutations.push([false,true,true,false,false]);
        _selectionPermutations.push([false,true,false,true,false]);
        _selectionPermutations.push([false,true,false,false,true]);
        _selectionPermutations.push([true,true,false,false,false]);
        _selectionPermutations.push([true,false,true,false,false]);
        _selectionPermutations.push([true,false,false,true,false]);
        _selectionPermutations.push([true,false,false,false,true]);

        // 1 match
        _selectionPermutations.push([false,false,false,true,false]);
        _selectionPermutations.push([false,false,false,false,true]);
        _selectionPermutations.push([false,false,true,false,false]);
        _selectionPermutations.push([false,true,false,false,false]);
        _selectionPermutations.push([true,false,false,false,false]);
    }

    function _validateParts(
        DreamNounRequest memory nounDefinition
    ) internal view returns(bool)
    {
        // Ensure at least 1 attribute is provided
        require(
            nounDefinition.IncludeBackground != false || 
            nounDefinition.IncludeBody != false || 
            nounDefinition.IncludeAccessory != false || 
            nounDefinition.IncludeHead != false || 
            nounDefinition.IncludeGlasses != false,
            'At least one attribute must be provided'
        );

        if(nounDefinition.IncludeBackground)
        {
            uint256 backgroundCount = _nounsDescriptorMinimal.backgroundCount();
            require(nounDefinition.Background <= backgroundCount, 'Background value is not within the bounds');
        }

        if(nounDefinition.IncludeBody)
        {
            uint256 bodyCount = _nounsDescriptorMinimal.bodyCount();
            require(nounDefinition.Body <= bodyCount, 'Body value is not within the bounds');
        }

        if(nounDefinition.IncludeAccessory)
        {
            uint256 accessoryCount = _nounsDescriptorMinimal.accessoryCount();
            require(nounDefinition.Accessory <= accessoryCount, 'Accessory value is not within the bounds');
        }

        if(nounDefinition.IncludeHead)
        {
            uint256 headCount = _nounsDescriptorMinimal.headCount();
            require(nounDefinition.Head <= headCount, 'Head value is not within the bounds');
        }

        if(nounDefinition.IncludeGlasses)
        {
            uint256 glassesCount = _nounsDescriptorMinimal.glassesCount();
            require(nounDefinition.Glasses <= glassesCount, 'Glasses value is not within the bounds');
        }

        return true;
    }
}
