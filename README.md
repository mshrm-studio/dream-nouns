<p align="left">
  <img width="80" height="80" src="https://github.com/user-attachments/assets/b10e2e8a-d5b7-4aaf-9bc2-10d725a15cfe">
  <img width="80" height="80" src="https://github.com/user-attachments/assets/c227fa4f-42b3-44c8-8452-f12cb83e29a5">
  <img width="80" height="80" src="https://github.com/user-attachments/assets/f126bdca-8aa8-491a-a898-fb5b2cc32ea8">
  <img width="80" height="80" src="https://github.com/user-attachments/assets/f5e2ddca-abcd-46d2-8861-ffe8f4b5f3c6">
</p>

# Dream-Nouns :heart_eyes:

A way to get a little extra chance for your most desired Noun to get generated. 

## Contracts :page_facing_up:

### Dream Nouns Contract 

Offers the following functionality:

- Allows users to be able to upload their dream noun (either all 5 traits can be provided or as little as only 1)
- Allows us to be able to try to find a registered matched dream noun at noun o'clock
- Allows us to settle and create new auction for a desired noun if there is a match
- Allows for the get of dream noun data
- Allows for the get of dream noun probability
- Allows for the get of when it is noun o'clock 

## Test Dapps :construction:

Deployers Address: TBC.

| Contract      | Address       | Network       |
| ------------- | ------------- | ------------- |
| Dream Nouns | [TBC.](https://sepolia.etherscan.io/address/0xcdad459feee277dfee22856d763feb55edf963ba#code)     | Sepolia       | 

## Deploy/Setup Steps :construction_worker:

1. Have the following addresses ready:
    - The nouns token address
    - The nouns descriptor address
    - The nouns seeder address
    - The nouns auction house address
    - A spawner address (where funds get sent)
    - An address to manage the minimum deposit (an additional authority)
2. Deploy contract
3. Call populatePermutationSelections()

### Notes :clipboard:

- The Dream Nouns contract requires deployment using optimization with 2k runs

## Ecosystem :arrows_clockwise:

![Untitled (2)](https://github.com/user-attachments/assets/52380b76-ecc7-418a-88f1-2b29a5ffa6c6)

### Add Dream Noun :new:

![image](https://github.com/user-attachments/assets/d3b5b431-e3e1-4575-b2d3-3cb97960a8d1)

<!-- 
title Add Dream Noun

User->Dream Contract: Send deposit and call add dream noun with desired traits
Dream Contract->Dream Contract: Check deposit has been matched
Dream Contract->Nouns Descriptor Contract: Get head,body,background,accessory and glasses counts
Nouns Descriptor Contract->Dream Contract:Return counts
Dream Contract->Dream Contract: Validate the values for traits are in bounds
Dream Contract->Dream Contract: Turn the dream noun into a key ie. "x-12-1-x-4"
Dream Contract->Dream Contract: Check the key does not already have a match (someone elses open request)
Dream Contract->Spawn Manager: Move deposit to fund manager
Dream Contract->Dream Contract: Save dream noun & index to user
Dream Contract->Dream Contract: Fire successful dream noun created event
-->

### Try To Match Dream Noun

![image](https://github.com/user-attachments/assets/ab4696b3-2d3a-440b-bc98-aa4814ac9670)

<!-- 
title Match Dream Noun

Job->Dream Contract: Find dream match (if exists)
Dream Contract->Nouns Token Contract: Get total supply
Dream Contract->Dream Contract: Turn total suppy to next id
Dream Contract->Nouns Seeder Contract: Get seed for next noun to be minted
Dream Contract->Dream Contract: Get turn seed into traits key
Dream Contract->Dream Contract: Try to match traits key
Dream Contract-->Job: Return match and block number the match was generated on if matched 
-->

## How This Can Be Used :sparkles:

![image](https://github.com/user-attachments/assets/62028464-c6ce-4443-8ce2-2babbebb7767)

<!--
title Process Flow

Job->Dream Contract: Is Noun o'clock 
Dream Contract->Nouns Auction Contract: Is Noun o'clock
Nouns Auction Contract->Dream Contract: Return true
Dream Contract->Job: Return true 
Job->Dream Contract: Is there a match 
Dream Contract->Job: Return true, block number estimated from and the noun traits to be minted
Job->Dream Contract: Settle for block 
Dream Contract->Dream Contract: Is the block number the same as provided 
Dream Contract->Dream Contract: Remove mapped match + update users dream request 
Dream Contract->Nouns Auction Contract: Call settle & create new auction 
Nouns Auction Contract->Nouns Auction Contract: Settle 
Nouns Auction Contract->Nouns Auction Contract: Create new auction 
Dream Contract->Job: Return
-->
