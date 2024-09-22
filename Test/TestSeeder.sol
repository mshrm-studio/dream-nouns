// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.21.0;

import { INounsSeeder } from 'https://raw.githubusercontent.com/nounsDAO/nouns-monorepo/refs/heads/master/packages/nouns-contracts/contracts/interfaces/INounsSeeder.sol'; 
import { INounsDescriptor } from 'https://raw.githubusercontent.com/nounsDAO/nouns-monorepo/refs/heads/master/packages/nouns-contracts/contracts/interfaces/INounsDescriptor.sol';
import { INounsDescriptorMinimal } from 'https://raw.githubusercontent.com/nounsDAO/nouns-monorepo/refs/heads/master/packages/nouns-contracts/contracts/interfaces/INounsDescriptorMinimal.sol';

contract TestNounsSeeder is INounsSeeder 
{
    INounsSeeder.Seed public SeedValue;

    function generateSeed(uint256 nounId, INounsDescriptorMinimal descriptor) external view returns (INounsSeeder.Seed memory){
       return SeedValue;
    }

    function setSeed(uint48 a, uint48 b, uint48 c, uint48 d, uint48 e) external
    {
        SeedValue = INounsSeeder.Seed(a,b,c,d,e);
    }
}
