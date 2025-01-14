## fundMe智能合约

**从Cyfrin处学习**

- [原课程github](https://github.com/Cyfrin/foundry-fund-me-cu)

- [Cyfrin Updraft](https://updraft.cyfrin.io/courses)

## 常用命令行指令

### 文件夹操作

```shell
$ cd ..                            //退回上个文件夹
$ ls                               //查看文件夹下的所有文件
$ code foundry-simple-storage/     //跳转并打开文件夹下的项目
```

### 加载env资源

```shell
$ source .env
$ echo $SEPOLIA_RPC_URL
```

### foundry编译脚本

```shell
$ forge build
$ forge compile
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### git相关操作

```shell
$ git add .
$ git commit -m "描述你的更改"
$ git push -u origin master 
$ git remote -v 
$ git log
```
