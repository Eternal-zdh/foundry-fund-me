// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//详情见库合约的用法
library PriceConvert {
    //获取一个ETH的价格
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        //Sepolia测试网   地址address   0x694AA1769357215DE4FAC081bf1f309aDC325306
        //ABI   调用chainLink的接口
        //AggregatorV3Interface dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (
            /* uint80 roundID */,
            int256 answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        //得到的 answer 大约为 3000 多一些 3333 12345678，小数是8位，再乘以10位，就可以和以太坊的 1e18 wei 持平
        //就像这样   3456 * 1e18 usdt = 1e18 wei  即  3456 usdt = 1 ETH
        return uint256(answer * 1e10);
    }

    //输入ETH的数量，得到对应usdt的数量
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        //ethAmount实际上是wei的数量，乘完后是1e36，所以要除以1e18，注意要先乘后除
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsdt = ethPrice * ethAmount / 1e18;
        return ethAmountInUsdt;
    }
}
