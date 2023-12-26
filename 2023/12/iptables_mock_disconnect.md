# [iptables模拟服务端停机](/2023/12/iptables_mock_disconnect.md)

一天遇到coinex交易所停机维护两次，早上看到k线停了几个小时的柱子结果下午又停机，真的需要测试下策略机器人对交易所停机维护的鲁棒性，正好可用iptables去模拟网络阻断

列出和编辑iptables规则:

```
iptables -L
iptables-save > iptables_rules.txt
vim iptables_rules.txt
iptables-restore < iptables_rules.txt
```

```
dig api.gateio.ws
iptables -A OUTPUT -p tcp -d 18.182.179.133 -j DROP
# 然后 curl 就卡住了
w@DESKTOP-SV7LDNF:~$ curl -v https://api.gateio.ws/api/v4/spot/time
*   Trying 18.182.179.133:443...
* TCP_NODELAY set
```
