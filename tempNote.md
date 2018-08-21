外键约束的类型有三种：

no action：默认 A部门有人不能直接删掉A部门字段

set null：删掉A部门后，原A部门雇员的部门编号设为NULL

cascade级联 删掉A部门后同时删掉A部门所有雇员的记录