# WIP...

- add busyjayles reply why not use std::path::canoize on slack
- add cgcreate example

How to test test-cgroup feature

## PR info

pr commit msg reference:
- <https://github.com/tikv/tikv/pull/11095>
- <https://github.com/tikv/tikv/pull/11164>

### PR title

### PR commit msg

tikv_util: fix test-cgroup feature compile error and improve path normalized

tikv_util: fix test-cgroup feature compile error

### PR 的文案

```
# Fix test-cgroup feature compile error and 
cargo test --package=tikv_util --features test-cgroup
```



[w@ww tikv]$ systemd-run --user --scope -p MemoryMax=27G make test
Running scope as unit: run-rb95be102148247059e5fbf2cfcee2dcb.scope

...

systemd[698]: run-rb95be102148247059e5fbf2cfcee2dcb.scope: A process of this unit has been killed by the OOM killer

---

[components/tikv_util/src/sys/cgroup.rs:81] &self.mount_points = {
    "": (
        "/",
        "/sys/fs/cgroup",
    ),
}
[components/tikv_util/src/sys/cgroup.rs:82] &self.cgroups = {
    "": "/tikv-test-2357800",
}
[components/tikv_util/src/sys/cgroup.rs:83] self.is_v2 = true

