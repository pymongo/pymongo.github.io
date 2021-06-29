# [tensorbase](/2021/06/tensorbase.md)

Getting Started with

## what is tensorbase

A data warehouse using yandex's clickhouse protocol

data warehouse is different to database, data warehouse is very fast to query and slow to insert

data warehouse usually used in offline data analysis

## run clickhouse server

according to tensorbase's README.me

> cargo run --bin server

```
05:18:29 [INFO] [Base] built in debug mode
thread 'main' panicked at 'Can not load configurations via default location (conf/base.conf) or command-line arguments', crates/runtime/src/mgmt.rs:128:9
```

reference install steps from  tensorbase document: [Get Started for Users](https://github.com/tensorbase/tensorbase/blob/main/docs/get_started_users.md)

the tensorbase example config file have a clickhouse field, I guess need to install clickhouse server

### systemd start clickhouse-server

```
$ yay -S clickhouse-server-bin
$ sodo systemctl status clickhouse-server
$ sudo systemctl start clickhouse-server
```

### clickhouse-client

alternative: use DataGrip GUI clickhouse client

> yay -S clickhouse-client-bin

clickhouse's command is very similar to MySQL, example `show databases`

```
[w@ww tensorbase]$ clickhouse-client 
ClickHouse client version 21.5.6.6 (official build).
Connecting to localhost:9000 as user default.
Connected to ClickHouse server version 21.5.6 revision 54448.

ww :) show databases
┌─name────┐
│ default │
│ system  │
└─────────┘
```

## tensorbase conf

config file example is `crates/server/tests/confs/base.conf`

MySql/mongodb usually storage data on `/var/lib/mongodb` and config in `/etc/mongodb`

I guess clickhouse's config file and data dir is similar to mongodb

Also same as mongodb, `/var/lib/clickhouse` dir permission/user_group is clickhouse/clickhouse

here is my tensorbase config file:

```
[system]
meta_dirs = ["/home/w/temp/tensorbase_storage/tb_schema"]
data_dirs = ["/home/w/temp/tensorbase_storage/tb_data"]

[storage]
data_dirs_clickhouse = "/var/lib/clickhouse/data"

[server]
ip_addr = "localhost"
port = 9528
```

Run tensorbase server:

```
[w@ww tensorbase]$ cargo run --bin server -- -c /home/w/temp/tensorbase_storage/tensorbase.conf
    Finished dev [unoptimized + debuginfo] target(s) in 0.08s
     Running `target/debug/server -c /home/w/temp/tensorbase_storage/tensorbase.conf`
05:41:48 [INFO] [Base] built in debug mode
05:41:48 [INFO] confs to use:
05:41:48 [INFO] system.meta_dirs: ["/home/w/temp/tensorbase_storage/tb_schema"]
05:41:48 [INFO] system.data_dirs: ["/home/w/temp/tensorbase_storage/tb_data"]
05:41:48 [INFO] server.ip_addr: "localhost"
05:41:48 [INFO] server.port: 9528
05:41:48 [INFO] current timezone sets to Etc/GMT-8
05:41:48 [INFO] database `system` created
05:41:48 [INFO] database `default` created
05:41:48 [INFO] Starting 24 workers
05:41:48 [INFO] Starting "base_srv" service on [::1]:9528
```

use clickhouse-client to connect tensorbase server

```
[w@ww clickhouse]$ clickhouse-client --port 9528
ClickHouse client version 21.5.6.6 (official build).
Connecting to localhost:9528 as user default.
Connected to TensorBase server version 2021.5.0 revision 54405.

ClickHouse client version is older than ClickHouse server. It may lack support for new features.
```

## import sample data

clickhouse has sample data like `New York Taxi Data` which introduce on rustconf china 2020

But I'd like to use clickhouse's sample data `Cell Towers`

Here is how clickhouse create database cell_towers, tensorbase is similar

I want to insert same data to clickhouse and tensorbase to compare performance

```
ww :) create database cell_towers;
ww :) show databases;
┌─name────────┐
│ cell_towers │
│ default     │
│ system      │
└─────────────┘
ww :) use cell_towers
ww :) select database();
┌─DATABASE()──┐
│ cell_towers │
└─────────────┘
```

### tensorbase not support Enum8

tensorbase use BaseStorage ENGINE, clickhouse use MergeTree ENGINE

since tensorbase not pupport Enum8, I change Enum8 to String 

```
CREATE TABLE cell_towers
(
    radio String,
    mcc UInt16,
    net UInt16,
    area UInt16,
    cell UInt64,
    unit Int16,
    lon Float64,
    lat Float64,
    range UInt32,
    samples UInt32,
    changeable UInt8,
    created DateTime,
    updated DateTime,
    averageSignal UInt8
)
ENGINE = BaseStorage
```

## tensorbase not support FORMAT CSVWithNames

So I use `FORMAT CSV` to insert

clickhouse-client --compression true --port 9528 --query "INSERT INTO cell_towers.cell_towers FORMAT CSV" < cell_towers_no_headers.csv

for clickhouse-client version >= 21.5, need to add `--compression true` arg to make INSERT statement successful
