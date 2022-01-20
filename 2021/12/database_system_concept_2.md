# [database system 读书笔记 2](/2021/12/database_system_concept_2.md)

progress: page 94

## SQL types

### varchar
char(10) 会往右 padding 空格固定为长度 10，
char 和 varchar 之间比长度(或者字符串之间比长度)如果长度不一样将较短的填充空格成一样长再比较

### string
MySQL 的字符串 literal 比较是 case in-sensitive 的(好像能在配置中改)

§ like, % match any substring while _ match a char

- MySQL/pg like pattern is case in-sensitive
- pg can use **ilike** to make like pattern case sensitive
- pg 还有个 **similar to**, 以及 ~ 波浪号表示正则
- foo% : starts_with("foo")
- %foo%: contains("foo")
- ____%: any string at least 4 chars

### NULL

BinaryOperand 遇到 NULL 会返回 unknown 例如表达式 `1 < NULL` 的值是 unknown (在 MySQL 中是 NULL)

> MariaDB [(none)]> select 1 from dual where 1 is not unknown;

所以 `null = null` 会返回 unknown, 但是在 distinct 中多个 null 会被去重(因为 null=null 返回 true)

aggregate function 会忽略掉 NULL 值，agg 空集合时，count 返回 0 其余 agg 函数返回 NULL

只要有一个属性是 NULL, unique 就会返回 NULL

---

```sql
select distinct T.name
from instructor as T, instructor as B -- 为什么需要 AS 因为需要自我关联的场合就只能用 AS
where T.salary > B.salary and B.dept_name = 'B';
```

T 的工资虽然会跟所有部门 B 的员工工资比，但只要比 B 部分工资最低的员工高就能满足 select operator 的过滤，
所以优化成比 B 部分最低工资多就行

早期的 SQL 标准没有 AS 所以 oracle 等数据库的 select/from clause 中可以省略 as

`=Some` 相当于 `in`, `<>Some` 相当于 `not in`

---

## lateral clause
派生表, lateral join，一般用于某些需要自关联的子查询

## with clause
用于生成一张临时表，有时候比子查询的可读性要好

```sql
sqlite> .schema department
CREATE TABLE department
	(dept_name		varchar(20), 
	 building		varchar(15), 
	 budget		        numeric(12,2) check (budget > 0),
	 primary key (dept_name)
	);
sqlite> .schema instructor
CREATE TABLE instructor
	(ID			varchar(5), 
	 name			varchar(20) not null, 
	 dept_name		varchar(20), 
	 salary			numeric(8,2) check (salary > 29000),
	 primary key (ID),
	 foreign key (dept_name) references department (dept_name)
		on delete set null
	);

-- 查询哪些部门平均工资高于所有部门平均工资
sqlite> with
    dept_total(dept_name,sum_salary)
    as (select dept_name, sum(salary) from instructor group by dept_name),
    dept_total_avg(avg_sum_salary)
    as (select avg(sum_salary) from dept_total)
select dept_name, sum_salary
from dept_total, dept_total_avg
where dept_total.sum_salary > dept_total_avg.avg_sum_salary;
Comp. Sci.|232000
Finance|170000
Physics|182000
```

## correlation
子查询引用了外部作用域的变量

```sql
select
    dept_name,
    (select count(*)
	from instructor
	where department.dept_name = instructor.dept_name)
from department;
```

## scalar subquery
子查询返回一个值

## coalesce()
用于表达 val if val is not null else DEFAULT_VAL 的逻辑，用 coalesce 会比 case-when-else 语句更简洁

## crossjoin/Cartesian product

```
...
Tanaka|EE-181
Tanaka|CS-101
Tanaka|CS-315
Tanaka|BIO-101
Tanaka|BIO-301
sqlite> explain select name, course_id from student cross join takes;
addr  opcode         p1    p2    p3    p4             p5  comment      
----  -------------  ----  ----  ----  -------------  --  -------------
0     Init           0     11    0                    0   Start at 11
1     OpenRead       0     14    0     2              0   root=14 iDb=0; student
2     OpenRead       2     17    0     k(6,,,,,,)     0   root=17 iDb=0; sqlite_autoindex_takes_1
3     Rewind         0     10    0                    0   
4       Rewind         2     9     1     0              0   
5         Column         0     1     1                    0   r[1]=student.name
6         Column         2     1     2                    0   r[2]=takes.course_id
7         ResultRow      1     2     0                    0   output=r[1..2]
8       Next           2     5     0                    1   
9     Next           0     4     0                    1   
10    Halt           0     0     0                    0   
11    Transaction    0     0     11    0              1   usesStmtJournal=0
12    Goto           0     1     0                    0   
```

## natural join

> select name,course_id from student,takes where student.ID = takes.ID;

is same as

> select name,course_id from student natural join takes where student.ID = takes.ID; -- or using ID

|||
|---|---|
|cross join|Cartesian product, not a set addition|
|natural join|default inner join, can set to left/right outer join|
|inner join|a.intersect(b)|
|left outer join| f b not in a, all b fields would NULL|
|right outer join|if a not in b, all a fields would NULL|
|full outer join|preserve all tuple in both relations|

join ... on 和 join .. where 是不太一样的，在 outer join 结果会不一样

## view

虽然 with_clause/sub_query 也能模拟需要，但不方便，用 view 还能让表中数据变动时同步更新到 view(需要用 materialized view 才能同步更新)

需求: 员工表的工资应该是保密的，所以员工表除了工资以外的字段可以做成 view 开放权限给普通级别的员工看


