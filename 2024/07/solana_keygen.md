# [solana-keygen](/2024/07/solana_keygen.md)

## grind

Grind for vanity keypairs, grind 指的是生成固定前缀的地址

用法 `solana-keygen grind --starts-with <prefix>`

我想到应用场景是 **0 转账攻击** <https://x.com/33357xyz/status/1809847602583925114>

由于钱包软件转账记录只会显示对方地址的前6和后6位，黑客利用用户复制上次转账地址的习惯，伪造一个首尾跟用户频繁转账的地址相同地址给用户转账，骗取用户复制到错误的地址

## 两种 keypair 生成方法

核心逻辑在 solana 源码 `keygen/src/keygen.rs` 和 `clap-utils/src/keypair.rs`

```rust
pub fn keypair_from_seed_phrase(
    keypair_name: &str,
    skip_validation: bool,
    confirm_pubkey: bool,
    derivation_path: Option<DerivationPath>,
    legacy: bool,
) -> Result<Keypair, Box<dyn error::Error>> {
    let seed_phrase = prompt_password(format!("[{keypair_name}] seed phrase: "))?;
    let seed_phrase = seed_phrase.trim();
    let passphrase_prompt = format!(
        "[{keypair_name}] If this seed phrase has an associated passphrase, enter it now. Otherwise, press ENTER to continue: ",
    );

    let keypair = if skip_validation {
        let passphrase = prompt_passphrase(&passphrase_prompt)?;
        if legacy {
            keypair_from_seed_phrase_and_passphrase(seed_phrase, &passphrase)?
        } else {
            let seed = generate_seed_from_seed_phrase_and_passphrase(seed_phrase, &passphrase);
            keypair_from_seed_and_derivation_path(&seed, derivation_path)?
        }
    }
    // ...
}
```

可以看到 solana 有两种 keypair 的生成方式

### solflare

助记词: cereal uniform print regret once ocean oxygen okay exclude hollow force obtain

地址: EpCkVjyF571saE6wdckx1LSWkYsDQPS3qNNdbkGiCfNt

(为了教学演示泄露了助记词，浏览器删掉钱包插件应该就能清空掉这个已泄露的助记词了吧)

**`solana-keygen recover --outfile temp`**

> Recovered pubkey `"BQPEK47UNACymPru3mdDnPbRbphRzoL4JfbJotVVgfSi"`. Continue? (y/n):

可见恢复出的地址不对 `solana-keygen new` 和 `solana-keygen recover` 默认都用 legacy 方法进行 助记词->私钥 转换

solana cli 导入助记词 需要加上参数 **`'prompt://?key=0/0'`** 指明用 derive_path 方法处理助记词，这样就得到跟 solflare 钱包一样的地址了

```
w@w:~/sol_keys$ solana-keygen recover 'prompt://?key=0/0' --outfile temp
[recover] seed phrase:
[recover] If this seed phrase has an associated passphrase, enter it now. Otherwise, press ENTER to continue:
Recovered pubkey `"EpCkVjyF571saE6wdckx1LSWkYsDQPS3qNNdbkGiCfNt"`. Continue? (y/n):
```

用 typescript 写个单元测试进行验证

```typescript
import * as bip39 from 'bip39';
// const bip39 = require('bip39');
import { Keypair } from '@solana/web3.js';
import { derivePath } from 'ed25519-hd-key';
test('sol_mnemonic', () => {
    const mnemonic = "cereal uniform print regret once ocean oxygen okay exclude hollow force obtain";
    // https://solana.com/developers/cookbook/wallets/restore-from-mnemonic
    const derivationPath = `m/44'/501'/0'/0'`; // SOL奇葩的是没有UTXO找零地址change
    const seed = bip39.mnemonicToSeedSync(mnemonic);
    const derivedSeed = derivePath(derivationPath, seed.toString('hex')).key;
    const keypair = Keypair.fromSeed(derivedSeed);
    expect(keypair.publicKey.toBase58()).toBe("EpCkVjyF571saE6wdckx1LSWkYsDQPS3qNNdbkGiCfNt");
});
```

### 幻影钱包

跟 solflare 一样用的 助记词+derive_path 生成私钥，过程就不演示了

看来主流钱包都不用这个 legacy 方式的地址生成，开发者不需要掌握 legacy keypair 生成规则

## Rust实现助记词解析

```rust
let mnemonic = bip39::Mnemonic::parse_in_normalized(bip39::Language::English, mnemonic).unwrap();
let seed = mnemonic.to_seed("");

let coin_type_sol = 501;
let account_idx = 0;
let addr_idx = 0;
// SOL比较奇葩derive_path没有找零地址 https://solana.com/developers/cookbook/wallets/restore-from-mnemonic
// let change = 0; // UTXO找零地址
let derivation_path = format!("m/44'/{coin_type_sol}'/{account_idx}'/{addr_idx}'");
let derivation_path: ed25519_dalek_bip32::DerivationPath =
    derivation_path.parse().unwrap();
let private_key = ed25519_dalek_bip32::ExtendedSigningKey::from_seed(&seed)
    .unwrap()
    .derive(&derivation_path)
    .unwrap();

let indexes = vec![
    44 | (1 << 31),
    coin_type_sol | (1 << 31),
    account_idx | (1 << 31),
    // change,
    addr_idx,
];
// let indexes2 = [
//     ChildIndex::hardened(44).unwrap(),
//     ChildIndex::hardened(coin_type_sol).unwrap(),
//     ChildIndex::hardened(0).unwrap(),
//     ChildIndex::normal(0).unwrap(),
// ];
// let private_key2 = ed25519_dalek_bip32::ExtendedSigningKey::from_seed(&seed)
//     .unwrap()
//     .derive(&indexes2)
//     .unwrap();
// assert_eq!(private_key.signing_key, private_key2.signing_key);
let private_key3 = slip10_ed25519::derive_ed25519_private_key(&seed, &indexes);
assert_eq!(private_key.signing_key.to_bytes(), private_key3);
```

## slip10_ed25519和ed25519_dalek_bip32

两个库 slip10_ed25519 和 ed25519_dalek_bip32 都能将 seed 处理成 私钥

slip10_ed25519 是 sui 源码在用，由于 Rust 孤儿规则限制，sui 用 new type 设计模式包了下 ed25519 去实现 sui 源码定义的 fastcrypto 或者 signer 相关 trait

## solana-keygen 导入导出助记词

### legacy 版本(不常用了)

```
w@w:~/sol_keys$ solana-keygen new --no-bip39-passphrase --outfile no_derive_path
Generating a new keypair
Wrote new keypair to no_derive_path
=================================================================================
pubkey: 8sP2do52kmKYGiWiDRs2hRQRr8KJviS36u3nyzxs2Azs
=================================================================================
Save this seed phrase to recover your new keypair:
issue name secret genuine emerge appear please midnight have clown peanut catalog
=================================================================================
w@w:~/sol_keys$ solana-keygen recover --outfile no_derive_path.recover
[recover] seed phrase:
[recover] If this seed phrase has an associated passphrase, enter it now. Otherwise, press ENTER to continue:
Recovered pubkey `"8sP2do52kmKYGiWiDRs2hRQRr8KJviS36u3nyzxs2Azs"`. Continue? (y/n):
```

### bip44 版本

```
w@w:~/sol_keys$ solana-keygen new --no-bip39-passphrase --derivation-path --outfile has_derive_path
Generating a new keypair
Wrote new keypair to has_derive_path
=======================================================================
pubkey: FzeVW4z1pwdJbAqDxZdgQUA3BqMa7JFXFzJ9HVWmRgWH
=======================================================================
Save this seed phrase to recover your new keypair:
chef any album file avocado struggle during hair bird detail leave drip
=======================================================================

w@w:~/sol_keys$ solana-keygen pubkey has_derive_path
FzeVW4z1pwdJbAqDxZdgQUA3BqMa7JFXFzJ9HVWmRgWH
w@w:~/sol_keys$ solana-keygen verify FzeVW4z1pwdJbAqDxZdgQUA3BqMa7JFXFzJ9HVWmRgWH has_derive_path
Verification for public key: FzeVW4z1pwdJbAqDxZdgQUA3BqMa7JFXFzJ9HVWmRgWH: Success

w@w:~/sol_keys$ solana-keygen recover 'prompt://?key=0/0' --outfile has_derive_path.recover
[recover] seed phrase:
[recover] If this seed phrase has an associated passphrase, enter it now. Otherwise, press ENTER to continue:
Recovered pubkey `"FzeVW4z1pwdJbAqDxZdgQUA3BqMa7JFXFzJ9HVWmRgWH"`. Continue? (y/n):
```

keygen new 生成出来的密钥，通过 `solana config set --keypair /path/to/id.json` 即可切换账户

## sol/sui cli 相似命令

||sol|sui|
|---|---|---|
|导入账户助记词|solana-keygen recover 'prompt://?key=0/0'|keytool import '$mnemonic' ed25519|
|获取账户地址|address|client active-address|
|获取账户余额|balance|client balance|
|切换账户|config set --keypair $path|client switch --address $alias|
|获取rpc地址|config get|client envs|
