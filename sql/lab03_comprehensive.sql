/* =========================================================
   数据库原理及应用 · 第三章 综合实验
   教学数据库：S（学生）、C（课程）、SC（选课）、T（教师）
   注：字段类型依据实验中用到的列推断，课程报告原文以图示给出表结构。
   ========================================================= */

-- 建库
IF DB_ID('teachdb') IS NULL
    CREATE DATABASE teachdb;
GO
USE teachdb;
GO

-- ========== 1. 用 DDL 创建 S、C、SC、T 四张表（S# 为主键，SN 不能为空） ==========
CREATE TABLE S (
    S#   CHAR(4)      PRIMARY KEY,
    SN   CHAR(20)     NOT NULL,
    AGE  INT,
    DEPT CHAR(20)
);

CREATE TABLE C (
    C# CHAR(4)  PRIMARY KEY,
    CN CHAR(20)
);

CREATE TABLE T (
    T#   CHAR(4)   PRIMARY KEY,
    TN   CHAR(20),
    SAL  INT,          -- 工资
    COMN INT,          -- 津贴
    C#   CHAR(4)
);

CREATE TABLE SC (
    S#  CHAR(4),
    C#  CHAR(4),
    GR  INT,           -- 成绩
    PRIMARY KEY (S#, C#),
    FOREIGN KEY (S#) REFERENCES S(S#),
    FOREIGN KEY (C#) REFERENCES C(C#)
);
GO

-- ========== 2. 向四张表添加数据（用 SQL 语句实现） ==========
INSERT INTO S VALUES ('S1','丁一',20,'计算机'), ('S2','王二',19,'计算机'), ('S3','张三',19,'外语');
INSERT INTO C VALUES ('C1','数据库'), ('C2','操作系统'), ('C3','微机原理');
INSERT INTO T(T#,TN,SAL,C#) VALUES ('T1','王力',800,'C1');
INSERT INTO T VALUES ('T2','张兰',1200,300,'C1'), ('T3','李伟',700,150,'C2');
INSERT INTO SC VALUES ('S1','C1',80), ('S1','C2',89), ('S2','C3',59), ('S2','C2',75);
GO

-- ========== 3. 创建计算机系学生的视图（学号、姓名、课程号、任课教师号） ==========
CREATE VIEW 计算机系学生 AS
SELECT SC.S#, SN, SC.C#, T#
FROM S, C, T, SC
WHERE S.S# = SC.S# AND SC.C# = T.C# AND T.C# = C.C#;
GO

-- ========== 4. 检索计算机系年龄在 19 岁以上的学生学号 ==========
SELECT S#
FROM S
WHERE AGE > 19 AND DEPT = '计算机';
GO

-- ========== 5. 检索姓王的教师所讲课程的课程号及课程名称 ==========
SELECT C#, CN
FROM C
WHERE C# = (SELECT C# FROM T WHERE TN LIKE '王%');
GO

-- ========== 6. 检索丁一同学所学课程的成绩，列出 SN、C#、GR，并按成绩降序排列 ==========
SELECT SN, C#, GR
FROM S, SC
WHERE SN = '丁一' AND SC.S# = S.S#
ORDER BY GR DESC;
GO

-- ========== 7. 检索选修总收入超过 1000 元的教师所讲课程的学生姓名、课程号和成绩 ==========
SELECT SN, SC.C#, GR
FROM T, S, SC
WHERE (SAL + COMN > 1000) AND (T.C# = SC.C#) AND (S.S# = SC.S#);
GO

-- ========== 8. 检索选修 C1 课程且选修课程数为两门的学生的姓名和平均成绩 ==========
SELECT SN, AVG(GR) AS 平均成绩
FROM S, SC
WHERE S.S# = SC.S# AND S.S# IN (
        SELECT S# FROM SC WHERE C# = 'C1'
    )
  AND S.S# IN (
        SELECT S# FROM SC GROUP BY S# HAVING COUNT(*) = 2
    )
GROUP BY SN;
GO

-- ========== 9. 检索选修和王二同学所选课程中任意一门相同的学生姓名、课程名 ==========
SELECT SN, CN
FROM S, SC, C
WHERE S.S# = SC.S# AND C.C# = SC.C#
  AND C.C# IN (SELECT C.C# FROM S, SC, C
               WHERE S.S# = SC.S# AND SN = '王二')
  AND SN <> '王二';
GO

-- ========== 10. S1 同学选修了 C3，将此信息插入 SC 表中 ==========
INSERT INTO SC(S#, C#) VALUES ('S1', 'C3');
GO

-- ========== 11*. 删除 S 表中没有选修任何课程的学生记录 ==========
DELETE FROM S
WHERE S# NOT IN (SELECT DISTINCT S# FROM SC);
GO
