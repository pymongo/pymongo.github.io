# [database system 读书笔记 1](/2021/09/database_system_concept_1.md)

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

term relation instance to refer to a specific instance of a relation,

that is, containing a specific set of rows. The instance of instructor shown in Figure 2.1

has 12 tuples, corresponding to 12 instructors.
