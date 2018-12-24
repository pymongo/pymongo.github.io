# 日本語入力(输入法/IME)

首发于: 18-12-08 最后修改于: 18-12-17

## 中日英入力方案

中文输入法可按<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>F</kbd>切换繁体, 打出不认识的日本語漢字

但是这个快捷键与VScode文件夹内搜索热键冲突, 所以我把它改成<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>T</kbd>

输入法切换用<kbd>Alt</kbd>+<kbd>Space</kbd>比Win+Space方便

由于日语输入法日/英切换的快捷键<kbd>Alt</kbd>+<kbd>`</kbd>不顺手

我让中文输入法默认英文输入, 日语输入法下想输入英文时按Alt+Shift切换输入法即可

可惜日语输入法不能设置默认使用日语输入, 不然我设想的方案就完美了

## 日语输入法快捷键

日语输入法快捷键之多/功能之多绝对是我这辈子见过最难的输入法

完整的快捷键清单请看 IMEの詳細設定->キー , 至少有50多个快捷键组合

<details>
<summary>这个详细清单并不包括CapsLock键的组合, CapsLock快捷组合在win7下没有</summary>
<li>Change to Hiragana/Katakana: <kbd>Ctrl</kbd>/<kbd>Alt</kbd>+<kbd>CapsLock</kbd></li>
<li>Toggle between Hiragana and Alphanumeric: <kbd>Shift</kbd>+<kbd>CapsLock</kbd></li>
<li>Toggle between Last Used and Alphanumeric: <kbd>Alt</kbd>+<kbd>~</kbd></li>
</details>

我只列出我认为很实用很常用的快捷键

- <kbd>F6</kbd>/ <kbd>Ctrl</kbd>+<kbd>U</kbd> ひらがな変換
- <kbd>F7</kbd>/ <kbd>Ctrl</kbd>+<kbd>I</kbd> カタカナ変換
- <kbd>F10</kbd>/<kbd>Ctrl</kbd>+<kbd>T</kbd> 半角英数変換
- <kbd>Ctrl</kbd>+<kbd>A</kbd>/<kbd>S</kbd>/<kbd>D</kbd>/<kbd>F</kbd> 光标移动:行首/左/右/行末
- <kbd>Ctrl</kbd>+<kbd>H</kbd>/<kbd>G</kbd> 光标Backspace/Del
- <kbd>Ctrl</kbd>+<kbd>M</kbd>/<kbd>Z</kbd> 确认,同Enter/全删除

按完空格选完候选词后,Ctrl+M比Enter更容易按到

## 重新规划下AutoHotKey改建

Ctrl+S这个最容易按的键我在公司上设为"确认"

Win+WASD移动光标我也没怎么用, 左手拇指从Alt挪到win还不如让右手挪到方向键

## 片仮名入力方案

F7/Ctrl+I变换 或 Alt+Caps打完后再用shift+CapsLock切回平仮名输入

如果输入的是片仮名词汇输完后按下空格即可转为片仮名, 这是最快的

## 片仮名翻译为英文

如果输入的片仮名词汇在IME词库, 按空格时, 第三个候选词是片仮名对应的英文单词

word的ルビ和翻訳(honyaku)機能(kino)以及IME的英語変換是我在日企上班读懂日语的好工具

## small kana(小假名)[捨て仮名]

小假名指的是半截高的假名,

拗音和外来語都是1大假名带1小假名,

取大假名辅音小假名原因, 如<kbd>nyu=にゅ</kbd>

用x或l+假名的romaji可打出单独一个小假名 如xe/le能打出ェ

26个字母没有任何带 x l q v的音 c也很少 这几个键基本不用

很多键都利用率很低 打字效率自然比不过kana输入法或中文拼音输入法

## 撥音歧义问题

翻訳(ほんやく)ho|n|ya|ku

会被IME误认为ほにゃくho|nya|ku

为了避免撥音n与后面的音**结合成n开头的拗音**如nya

在输入「ほｎ」的时候再打一个n「honn」=>「ほん」

两个nn连续则会解析成一个ん避免分词歧义

## 促音

可用打小假名的方法打出,但这样很慢

但是最高效的方法是,促音的下一个音必为辅音,如っ后面的是か

かka的辅音部分是k,那么我只需打出kka就会出来っか

> 举例: 作家(さっか)sakka 

## 長音(片仮名)

如 モータ 中间的一是长音, 用-dash符号来输入

> motorモータ(mo-ta)