# [foundry部署合约](/2024/06/foundry_deploy_on_local_network.md)

首先要获取下 geth "创世钱包" 的私钥

```python
import json
from eth_keyfile import decode_keyfile_json
keyfile_json = json.loads(open('execution/keystore/UTC--2022-08-19T17-38-31.257380510Z--123463a4b065722e99115d6c222f267d9cabb524').read())
passphrase = open('execution/geth_password.txt').read()
private_key = decode_keyfile_json(keyfile_json, passphrase.encode())
print(private_key.hex())
```

我用foundryup装的forge

> forge create src/Counter.sol:Counter --private-key xxx

vscode LSP 可以用 solidity 插件，forge默认用git submodule vendor第三方库代码

需要remap下路径让vscode LSP索引到第三方库 `forge remappings > remappings.txt`

foundry+geth部署能学到更多底层细节，比起remix在线IDE一键部署这样练出来基本功更扎实
