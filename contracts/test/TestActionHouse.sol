// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.21.0;

import { INounsAuctionHouseV2 } from 'https://raw.githubusercontent.com/nounsDAO/nouns-monorepo/refs/heads/master/packages/nouns-contracts/contracts/interfaces/INounsAuctionHouseV2.sol';

contract TestAuctionHouse is INounsAuctionHouseV2{
     function settleAuction() external{

     }

    function settleCurrentAndCreateNewAuction() external{

    }

    function createBid(uint256 nounId) external payable{

    }

    function createBid(uint256 nounId, uint32 clientId) external payable{

    }

    function pause() external{

    }

    function unpause() external{

    }

    function setTimeBuffer(uint56 timeBuffer) external{

    }

    function setReservePrice(uint192 reservePrice) external{

    }

    function setMinBidIncrementPercentage(uint8 minBidIncrementPercentage) external{

    }

    function auction() external view returns (AuctionV2View memory){

    }

    function getSettlements(
        uint256 auctionCount,
        bool skipEmptyValues
    ) external view returns (Settlement[] memory settlements){

    }

    function getPrices(uint256 auctionCount) external view returns (uint256[] memory prices){

    }

    function getSettlements(
        uint256 startId,
        uint256 endId,
        bool skipEmptyValues
    ) external view returns (Settlement[] memory settlements){

    }

    function getSettlementsFromIdtoTimestamp(
        uint256 startId,
        uint256 endTimestamp,
        bool skipEmptyValues
    ) external view returns (Settlement[] memory settlements){

    }

    function warmUpSettlementState(uint256 startId, uint256 endId) external{

    }

    function duration() external view returns (uint256){

    }

    function biddingClient(uint256 nounId) external view returns (uint32 clientId){
        
    }
}