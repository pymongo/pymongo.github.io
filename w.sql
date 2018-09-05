TRUNCATE lession;
TRUNCATE student;
CREATE TABLE lession(
    lid int,
    name VARCHAR(20) NOT NULL,
    CONSTRAINT pk_lid PRIMARY KEY(lid)
);
CREATE TABLE student(
    sid int,
    name VARCHAR(20) NOT NULL,
    lid int,
    CONSTRAINT pk_sid PRIMARY KEY(sid),
    CONSTRAINT fk_lid FOREIGN KEY(lid) REFERENCES lession(lid)
);
INSERT INTO lession VALUES(1,'math');
INSERT INTO lession VALUES(2,'english');
INSERT INTO student VALUES(1,'aa',1);
INSERT INTO student VALUES(2,'bb',1);
-- ORA-00001: unique constraint (SCOTT.PK_SID) violated
INSERT INTO student VALUES(2,'bb',2);
COMMIT;

SELECT s.name sname,l.name lname
FROM student s,lession l
WHERE s.lid = l.lid;