// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MockChainlinkPriceFeed is AggregatorV3Interface {
    int256 private price;
    uint8 private decimalsValue;
    uint80 private roundID;
    uint256 private startedAt;
    uint256 private updatedAt;
    uint80 private answeredInRound;

    constructor(int256 _initialPrice, uint8 _decimals) {
        price = _initialPrice;
        decimalsValue = _decimals;
        roundID = 1;
        startedAt = block.timestamp;
        updatedAt = block.timestamp;
        answeredInRound = 1;
    }

    function decimals() external view override returns (uint8) {
        return decimalsValue;
    }

    function description() external pure override returns (string memory) {
        return "MockChainlinkPriceFeed";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getRoundData(uint80 _roundID) external view override returns (
        uint80, 
        int256, 
        uint256, 
        uint256, 
        uint80
    ) {
        require(_roundID == roundID, "No data present for the round ID");
        return (roundID, price, startedAt, updatedAt, answeredInRound);
    }

    function latestRoundData() external view override returns (
        uint80, 
        int256, 
        uint256, 
        uint256, 
        uint80
    ) {
        return (roundID, price, startedAt, updatedAt, answeredInRound);
    }

    function setPrice(int256 _price) external {
        price = _price;
        updatedAt = block.timestamp;
        roundID++;
    }
}
