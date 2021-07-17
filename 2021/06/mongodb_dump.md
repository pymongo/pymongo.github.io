# [mongodb dump](/2021/06/mongodb_dump.md)

将服务器上 mongodb 所有库的数据同步到本地的脚步(或者用 ssh -L 隧道反向代理服务器上数据库端口到本地)

```bash
set -u

remote="centos@x.x.x.x"

dbs=("user" "orders" "trades")
for db in "${dbs[@]}"
do
    echo "dump $db from remote and restore to local"
    ssh $remote "mongodump --db $db --archive=$db.archive"
    scp "$remote:~/$db.archive" .
    mongorestore --stopOnError --drop --db $db --archive=$db.archive
done
```
