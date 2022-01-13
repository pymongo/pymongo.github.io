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
