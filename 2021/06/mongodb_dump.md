# [mongodb dump](/2021/06/mongodb_dump.md)

> [centos@remote_server ~]$ mongodump --db db_name --archive=db_name.archive
> 
> [w@dev_laptop ~]$ scp centos@remote_server:~/db_name.archive .
> 
> [w@dev_laptop ~]$ mongorestore --stopOnError --drop --db db_name --archive=db_name.archive

mongorestore's --drop arg means drop db_name all data before restore from db_name.archive
