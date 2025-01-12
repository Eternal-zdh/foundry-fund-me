// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./PriceConvert.sol";

error NotOwner();

contract FundMe {
    //将库合约中所有的函数添加为 uint256 的成员变量，之后任何 uint256 的变量都可以直接调用库合约里的函数
    using PriceConvert for uint256;

    //用户发送的最小货币不超过25刀 (constant常量gas更少)
    uint256 public constant MINIMUM_USDT = 25 * 1e18;

    //记录用户的列表,映射 地址 和 发送资金, 设置为private更节省gas
    address[] private  s_funders;
    mapping (address => uint256) private s_addressToFunders;

    //创建一个记录合约部署人的地址i_owner，s_priceFeed记录ETH价格的地址
    address public immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    // 构造函数 详见构造函数和修饰器 (immutable不变量gas更少)
    constructor(address priceFeed) {
        // 部署时，将ETH价格的地址作为参数传入合约
        //将owner设置为合约的部署者，获取ETH价格的地址传给s_priceFeed
        i_owner = msg.sender; 
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    //读取价格合约的版本
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    //接收钱的函数
    function fund() public payable {
        //payable修饰函数后，可以让合约地址接收ETH，如果接收的ETH不处理，将会永远锁在合约账户中
        //msg 是一个特殊的全局变量，代表了当前智能合约接收到的消息

        //这玩意还不能输入中文字符串
        //msg.value为uint256的函数，就可以直接调用库合约里的getConversionRate(),且msg.value作为第一个参数传入函数
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USDT, "You didn't send enough ETH!");  //1e18 = 1ETH
        s_funders.push(msg.sender);
        s_addressToFunders[msg.sender] = msg.value;
    }

    //将合约里的钱往外提，只能由合约部署者提取
    function withDraw() public onlyOwner {
        //读取storage上的东西是很费gas的，for s_funders.length，会多耗费大量的gas，将其抽出来只读取一次以节省gas
        uint256 fundersLength = s_funders.length;
        
        //遍历记录的地址列表，将映射内记录的资金数置空
        for (uint256 funderIndex = 0 ; funderIndex < fundersLength ; funderIndex++) 
        {
            //找到索引对应的地址
            address funder = s_funders[funderIndex];
            //将映射中对应地址的资金置空，因为资金已经被合约的发起者提走了
            s_addressToFunders[funder] = 0;
        }
        //将用户列表s_funders置空
        s_funders = new address[](0);

        //发送资金的方法有 transfer send call,前两个有2300gas限制，就用call就完了
        //调用call发送资金，向当前合约调用者发送该合约里的全部余额，一般都是集资人提款才用的       
        //address(this).balance 代表当前智能合约的全部余额
        (bool callSuccess, ) = payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess,"Call Failed");     //也可以把所有的requeire都变成自定义error
    }

    // 定义modifier修饰器，带有onlyOwner修饰符的函数只能被owner地址调用
    modifier onlyOwner {
        //require(msg.sender == owner,"Sender is not owner!"); // 检查调用者是否为owner地址
        if (msg.sender != i_owner) { revert NotOwner(); } //使用自定义error，且不输入字符串，能省下不少gas
        _; // 如果是的话，继续运行函数主体；否则报错并revert交易
    }

    //receive 和 fallback 详见接收eth，直接向合约转账时会触发，让其转到fund函数记录转账信息
    receive() external payable { fund();}
    fallback() external payable { fund();}

    /*********** view / pure function***********/
    function getAddressToFunders(address fundingAddress) external view returns (uint256) {
        //根据地址获取映射的值，不让外部直接获取s_addressToFunders这个映射，只能通过函数获取
        return s_addressToFunders[fundingAddress];
    }

    function getFunders(uint256 index) external view returns (address) {
        //根据索引获取对应用户的地址，不让外部直接获取s_funders这个列表，只能通过函数获取
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        //函数获取合约部署者的地址
        return i_owner;
    }
}
