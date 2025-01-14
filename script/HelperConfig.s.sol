// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//HelperConfig文件用于配置不同区块链的信息，不上链
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    //设置两个常量，记录anvil链模拟的价格
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 3639*1e8;

    //创建一个用于配置链信息的结构
    struct NetworkConfig {
        address priceFeed;
    }

    //实例化一个具体的对象
    NetworkConfig public activeNetworkConfig;
    constructor(){
        //在Solidity中，block对象提供了多个属性，帮助开发者获取和操作当前区块相关的信息
        //根据不同区块链ID，调用不同函数，传入不同的配置信息
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }else if(block.chainid == 1){
            activeNetworkConfig = getMainEthConfig();
        }else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }
     
    //sepolia
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }
    //mainETH
    function getMainEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return sepoliaConfig;
    }
    //anvil
    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        //如果对象地址不是0，就直接返回该对象，不需要vm重新开一个链
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        //这是用来获取价格的，部署时会在fundme之前部署，控制台上也会出现
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed:address(mockPriceFeed)
        });
        return anvilConfig;
    }
}