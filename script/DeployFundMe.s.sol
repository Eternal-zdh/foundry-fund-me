// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//用于部署合约的脚本，不上链
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe){
        
        HelperConfig helperConfig = new HelperConfig();
        address eth_usdt_price = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        //new关键字部署新的合约
        FundMe fundme = new FundMe(eth_usdt_price);
        vm.stopBroadcast();
        return fundme;
    }
}