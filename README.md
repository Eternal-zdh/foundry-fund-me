## fundMe智能合约

**从Cyfrin处学习**

- [原课程github](https://github.com/Cyfrin/foundry-fund-me-cu)

- [Cyfrin Updraft](https://updraft.cyfrin.io/courses)

## 常用命令行指令

### 文件夹操作

```shell
$ cd ..                            //退回上个文件夹
$ ls                               //查看文件夹下的所有文件
$ code html-fund-me-cu/     //跳转并打开文件夹下的项目
```

### 加载env资源

```shell
$ source .env
$ echo $DEFAULT_ANVIL_KEY
```

### foundry编译脚本

```shell
$ forge build
$ forge compile
```

### 执行测试命令，根据v的个数提高日志级别，详见foundry文档

```shell
$ forge test -vv
$ forge test --fork-url $SEPOLIA_RPC_URL  //在分叉环境中测试，不会对主网产生任何影响，分叉环境只能用于测试合约
$ forge test --match-test testFundUpdatesFundedDataStructure -vv
```

### Anvil

```shell
$ anvil
```

### 执行部署合约脚本 deploy 

```shell
$ forge script script/DeployFundMe.s.sol --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast 
$ forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --private-key 
```

### 查看测试的gas费用

```shell
$ forge snapshot --match-test testWithdrawWithMultipleFunder
```

### git相关操作

```shell
$ git add .
$ git commit -m "描述你的更改"
$ git push -u origin master 
$ git remote -v 
$ git log
```
