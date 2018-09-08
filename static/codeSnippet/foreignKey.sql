DROP TABLE lession CASCADE CONSTRAINT PURGE; -- 先删子，再删除父
DROP TABLE student CASCADE CONSTRAINT PURGE;
-- 父表student
CREATE TABLE student(
    sid INTEGER,
    name VARCHAR(8),
    CONSTRAINT pk_sid PRIMARY KEY(sid)
);
-- 外键引用了student
CREATE TABLE lession(
    name VARCHAR(20),
    sid INTEGER, -- one to many 一对多
    CONSTRAINT fk_stu FOREIGN KEY(sid) REFERENCES student(sid) ON DELETE CASCADE
);
/* 什么是父表
 * 先创建的是父表
 * 子表有外键约束引用父表 
*/
INSERT INTO student VALUES(1,'Smith');
INSERT INTO student VALUES(2,'Mike');
INSERT INTO lession VALUES('Math',1);
INSERT INTO lession VALUES('Math',2);
INSERT INTO lession VALUES('English',1);
INSERT INTO lession VALUES('English',2);

COMMIT;

SELECT l.name,s.name,s.sid
FROM lession l,student s
WHERE l.sid = s.sid;