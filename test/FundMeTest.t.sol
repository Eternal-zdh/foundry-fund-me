// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//用于测试智能合约，不上链
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    //创建一个用户地址，初始资金10eth，发送资金0.1eth
    address user = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant START_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        //设置地址和余额
        vm.deal(user,START_BALANCE);
    }

    /*-------------------------------测试时函数的执行逻辑-------------------------------*/
    //先执行一遍setUp,然后执行第一个test函数，再执行setUp，再执行第二个test函数，以此类推。。。。
    /*-------------------------------测试时函数的执行逻辑-------------------------------*/

    //测试转账最低要求是否为25u
    function test_MINIMUM_USDT_is_25() public view {
        assertEq(fundme.MINIMUM_USDT(),25e18);
    }
    //测试合约拥有者
    function test_Owner_is_MsgSender()  public view {
        console.log(fundme.i_owner());
        console.log(address(this));
        console.log(msg.sender);
        assertEq(fundme.getOwner(),msg.sender);
    }
    //测试chainLink价格的版本是否正确
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundme.getVersion();
        assertEq(version,4);
    }
    //测试eth不足时fund函数的失败情况
    function testFundFailWithoutEnoughEth() public {
        //指定预期某个交易会回滚（失败）。使用 vm.expectRevert() 可以帮助你测试智能合约在遇到错误时是否正确回滚。
        vm.expectRevert();
        fundme.fund();
    }


    modifier userFunded() {
        //vm.prank 模拟user地址，改变msg.sender
        vm.prank(user);
        //调用函数时，发送0.1个eth，只有paybale函数才能这么接收资金
        fundme.fund{value:SEND_VALUE}();
        _;
    }


    //测试合约接收资金时，记录的地址对应的资金 与发送方发送的资金是否相等
    function testFundUpdatesFundedDataStructure() public userFunded{
        //执行userFunded
        //通过函数找到映射中地址对应的资金，判断与发送的资金是否相等
        uint256 amountFunded =  fundme.getAddressToFunders(user);
        assertEq(amountFunded,SEND_VALUE);
    }
    //测试fund函数调用时，用户地址是否被正确推入用户列表s_funders
    function testAddsFunderToArrayOfFunders() public userFunded {
        //执行userFunded
        //索引检查用户列表s_funders，检查索引对应的地址是否为user
        address funder = fundme.getFunders(0);
        assertEq(user,funder);
    }
    //测试只有合约部署者可以调用withDraw提取资金
    function testOnlyOwnerCanWithdraw() public userFunded{
        vm.prank(user);
        vm.expectRevert();  //期望函数执行回滚
        fundme.withDraw();
    }
    //测试合约的资金是否能够正确提取，单个用户向合约存钱时
    function testWithdrawWithSingleFunder() public userFunded {
        uint256 startOwnerBalance = fundme.getOwner().balance;  //合约部署者的初始资金，取决于部署账户，假设为X  
        uint256 startFundMeBalance = address(fundme).balance;   //智能合约上存储的初始资金，userFunded给了0.1个eth

        //将msg.msg.sender更改为合约部署人i_owner，并调用withDraw()提取所有资金
        vm.prank(fundme.getOwner());
        fundme.withDraw();

        uint256 endOwnerBalance = fundme.getOwner().balance;    //此时合约部署者的资金应为 X+0.1 eth
        uint256 endFundMeBalance = address(fundme).balance;     //智能合约上存储的资金应为 0 
        assertEq(endFundMeBalance,0);
        assertEq( startOwnerBalance+startFundMeBalance , endOwnerBalance );
    }
    //测试合约的资金是否能够正确提取，多个用户向合约存钱时
    function testWithdrawWithMultipleFunder() public userFunded {
        uint160 numberOfFunders = 10;
        uint160 startFunderIndex = 1;
        for (uint160 i = startFunderIndex; i < numberOfFunders; i++) {
            //使用 hoax 函数来模拟多个地址向 fundme 合约发送eth
            hoax(address(i),SEND_VALUE);
            fundme.fund{value:SEND_VALUE}();
        }

        uint256 startOwnerBalance = fundme.getOwner().balance;  //合约部署者的初始资金，取决于部署账户，假设为X  
        uint256 startFundMeBalance = address(fundme).balance;   //智能合约上存储的初始资金，模拟的10个用户分别给了0.1个eth

        //startPrank 和 stopPrank 之间的所有操作都由合约所有者发起
        vm.startPrank(fundme.getOwner());
        fundme.withDraw();
        vm.stopPrank();

        uint256 endOwnerBalance = fundme.getOwner().balance;    //此时合约部署者的资金应为 X+1 eth
        uint256 endFundMeBalance = address(fundme).balance;     //智能合约上存储的资金应为 0 
        assertEq(endFundMeBalance,0);
        assertEq( startOwnerBalance+startFundMeBalance , endOwnerBalance );
    }
}
