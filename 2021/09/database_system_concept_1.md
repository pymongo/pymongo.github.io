# [database system 读书笔记 1](/2021/09/database_system_concept_1.md)

## current process

2.3 Database Schema, page 44

## 快速选中沙拉查词/firefox 的 pdf 阅读器进行反色

inspect($$('#viewerContainer')[0])

## relational algebra review

relational algebra 学术上用于无重复的数据集合/records，但现代数据库允许表中有重复行，因此可以推广到

| operator | Greek letter | SQL | notes |
| --- | --- | --- | --- |
| select | sigma(σ) | WHERE predicate | and(∧) or(∨) not(¬) |
| projection | pi(Π) | SELECT |
| Cartesian-product | cross(x) | CROSS JOIN |
| join | ⋈ |
| rename | rho(ρ) | AS |

### set operation
- union
- intersection
- except

## words

- obtained 48 patents: 拥有 48 项专利
- bibliographical: 书目信息
- exploit: 利用
- sophisticated: complex
- payroll: 工资表
- ubiquitous: 无所不在
- cybersecurity: 网络安全

## misc

constraint can be an arbitrary predicate(谓词) pertaining(与..关联) to the database

Data dictionary, which stores metadata about the structure of the database, in
particular the schema of the database

## query optimization

picks the lowest cost evaluation plan from among the alternatives

## ch2 (divider)

## DDL/DML/DQL

- DDL: CREATE/DROP/ALTER
- DML: INSERT/DELETE/UPDATE, Procedural/Declarative/nonprocedural(当今主流，数据库自动生成执行计划) DML
- DQL: SELECT

## terms

### relation instance

term *relation* instance to refer to a specific instance of a relation,

that is, containing a specific set of rows. The instance of instructor shown in Figure 2.1

has 12 tuples, corresponding to 12 instructors.

### tuple and attribute

- relations == table
- tuple == row
- attribute == field/attribute
- domain == attribute/字段 的可选值(a set of permitted values)
    * a domain is atomic: 字段是单个值，字段的值不是数组 ~~ atomic domain 相当于 unique 吧 ~~

A relationship between n values is represented mathematically by an
n-tuple of values, that is, a tuple with n values, which corresponds to a row in a table.
Thus, in the relational model the term relation is used to refer to a table, while the
term tuple is used to refer to a row. Similarly, the term attribute refers to a column of a
table.

### snapshot
- *database schema*: logic design of database
- *database instance*: a *snapshot* of the data in the database

### superkey
- *superkey*: 主键或者复合主键
- *candidate keys*/primary_key: superkey's and its subsets only one superkey
    也就是~~单个~~主键的意思，或者是复合主键但去掉任何一个复合主键tuple成员都会无法构成 pk
