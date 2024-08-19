# [SOL与wSOL转换](/2024/08/wrapped_solana_sync_native_instruction.md)

WETH智能合约就比ERC20多了deposit/withdraw进行转换

要获得wSOL需要了解一个指令叫 **`spl_token::instruction::sync_native`**

transfer指令(给wSOL的associated_token_addr转SOL) 和 sync_native指令 够了

```rust
fn main() {
    // ...
    let token_account = spl_associated_token_account::get_associated_token_address(&payer.pubkey(), &WSOL);
    let latest_block = client.get_latest_blockhash().unwrap();
    get_wsol_balance(&client, &token_account, &payer, latest_block);

    let amount = 1_000_000;
    let instruction = solana_sdk::system_instruction::transfer(&payer.pubkey(), &token_account, amount);
    let transaction = Transaction::new_signed_with_payer(
        &[instruction],
        Some(&payer.pubkey()),
        &[&payer],
        latest_block,
    );
    client.send_and_confirm_transaction(&transaction).unwrap();
    println!("after transfer {amount}");
    get_wsol_balance(&client, &token_account, &payer, latest_block);

    let ix = spl_token::instruction::sync_native(&spl_token::ID, &token_account).unwrap();
    let transaction = Transaction::new_signed_with_payer(
        &[ix],
        Some(&payer.pubkey()),
        &[&payer],
        latest_block,
    );
    client.send_and_confirm_transaction(&transaction).unwrap();
    println!("after sync_native {amount}");
    get_wsol_balance(&client, &token_account, &payer, latest_block);
}
fn get_wsol_balance(client: &RpcClient, token_account: &Pubkey, payer: &Keypair, latest_block: Hash)  {
    let account = match client.get_account(&token_account) {
        Ok(acc) => acc,
        Err(err) => match err.kind {
            solana_client::client_error::ClientErrorKind::RpcError(
                solana_client::rpc_request::RpcError::ForUser(err),
            ) => {
                println!("{}: {err}", line!());
                let create_account_instr = spl_associated_token_account::instruction::create_associated_token_account(
                    &payer.pubkey(),
                    &token_account,
                    &WSOL,
                    &spl_token::ID,
                );
                let mut transaction =
                    Transaction::new_with_payer(&[create_account_instr], Some(&payer.pubkey()));
                transaction.sign(&[&payer], latest_block);
                client.send_and_confirm_transaction(&transaction).unwrap();
                client.get_account(&token_account).unwrap()
            }
            _ => {
                panic!("{err}");
            }
        }  
    };
    let account_state = spl_token::state::Account::unpack(&account.data).unwrap();
    let sol = account_state.amount as f64 / 1e9;
    println!("wsol = {sol}, {} lamports", account_state.amount);
}
```

代码的输出如下，如果转账给wSOL不进行 sync_native 的话，wSOL 余额是没有更新的

```
wsol = 0.004, 4000000 lamports
after transfer 1000000
wsol = 0.004, 4000000 lamports
after sync_native 1000000
wsol = 0.005, 5000000 lamports
```

我们再看看 solana 源码中怎样进行 SOl->wSOL 的

<https://github.com/solana-labs/solana-program-library/blob/master/token/cli/src/command.rs#L1886>

spl-token cli 源码中，创建spl-token 并没有用 sync_native 原因是先transfer再init账户的话，init的时候相当于执行了类似sync_native的效果了

所以 `spl-token wrap` 命令在wSOL账户存在的时候转入wSOL会报错Error: Account already exists

只能用transfer+sync_native的方式

solana源码中提到:

> Burns tokens by removing them from an account. `Burn` does not support accounts associated with the native mint, use `CloseAccount` instead.

不能使用burn去销毁wSOL余额换回原生SOL, 只能用close把wSOL账户全部退回成SOL，不同于WETH合约可以部分提现WETH成ETH

`spl-token unwrap`实际上调用的是close account
