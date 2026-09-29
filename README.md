# SQL Server 数据库实验（教学数据库综合实验）

《数据库原理及应用》课程第三章综合实验。在 SQL Server 中用 SQL 命令完成建库建表、插入数据、创建视图，以及 11 道检索与更新题目。

## 环境要求

| 组件 | 版本 |
| --- | --- |
| SQL Server | 2016 以上 |
| 客户端 | SQL Server Management Studio（SSMS） |

无 Python 依赖。

## 数据模型

教学数据库含四张基本表：

| 表名 | 含义 | 主要字段 |
| --- | --- | --- |
| `S` | 学生表 | `S#`（学号，主键）、`SN`（姓名，非空）、`AGE`（年龄）、`DEPT`（系别） |
| `C` | 课程表 | `C#`（课程号，主键）、`CN`（课程名） |
| `SC` | 选课表 | `S#`、`C#`、`GR`（成绩） |
| `T` | 教师表 | `T#`（教师号，主键）、`TN`（姓名）、`SAL`（工资）、`COMN`（津贴）、`C#`（任课课程） |

## 实验内容

### 1. 用 DDL 创建四张表

要求 `S#` 为主键，`SN` 不能为空。

```sql
CREATE TABLE S (
    S#   CHAR(4) PRIMARY KEY,
    SN   CHAR(20) NOT NULL,
    AGE  INT,
    DEPT CHAR(20)
);
```

### 2. 用 SQL 语句插入数据

```sql
INSERT INTO S VALUES ('S1','丁一',20,'计算机'), ('S2','王二',19,'计算机'), ('S3','张三',19,'外语');
INSERT INTO C VALUES ('C1','数据库'), ('C2','操作系统'), ('C3','微机原理');
INSERT INTO T(T#,TN,SAL,C#) VALUES ('T1','王力',800,'C1');
INSERT INTO T VALUES ('T2','张兰',1200,300,'C1'), ('T3','李伟',700,150,'C2');
INSERT INTO SC VALUES ('S1','C1',80), ('S1','C2',89), ('S2','C3',59), ('S2','C2',75);
```

### 3. 创建视图

创建计算机系学生视图，属性列为学号、姓名、课程号和任课教师号：

```sql
CREATE VIEW 计算机系学生 AS
SELECT SC.S#, SN, SC.C#, T#
FROM S, C, T, SC
WHERE S.S# = SC.S# AND SC.C# = T.C# AND T.C# = C.C#;
```

### 4–11. 检索与更新题目

| 题号 | 题目 | 涉及能力 |
| --- | --- | --- |
| 4 | 检索计算机系年龄在 19 岁以上的学生学号 | 条件筛选 |
| 5 | 检索姓王的教师所讲课程的课程号及课程名称 | 嵌套子查询 + `LIKE` |
| 6 | 检索丁一同学所学课程的成绩，列出 SN、C#、GR，按成绩降序排列 | 多表连接 + 排序 |
| 7 | 检索选修总收入超过 1000 元的教师所讲课程的学生姓名、课程号和成绩 | 三表连接 + 计算条件 |
| 8 | 检索选修 C1 课程且选修课程数为两门的学生的姓名和平均成绩 | 分组 + `HAVING` |
| 9 | 检索选修和王二同学所选课程中任意一门相同的学生姓名、课程名 | `IN` 子查询 + 自连接 |
| 10 | S1 同学选修了 C3，将此信息插入 SC 表中 | `INSERT` |
| 11 | 删除 S 表中没有选修任何课程的学生记录 | `DELETE` + `NOT IN` 子查询 |

示例（第 6 题）：

```sql
SELECT SN, C#, GR
FROM S, SC
WHERE SN = '丁一' AND SC.S# = S.S#
ORDER BY GR DESC;
```

示例（第 11 题）：

```sql
DELETE FROM S
WHERE S# NOT IN (SELECT DISTINCT S# FROM SC);
```

完整脚本见 `sql/lab03_comprehensive.sql`。

## 运行

1. 用 SSMS 连接本地 SQL Server 实例。
2. 新建查询窗口，打开 `sql/lab03_comprehensive.sql`。
3. 先执行建库语句，切换到目标库后再依次执行建表、插数、视图与各题 SQL。

## 目录结构

```
sql-server-labs/
├── README.md
├── requirements.txt
├── .gitignore
└── sql/
    └── lab03_comprehensive.sql    # 建库建表 + 插数 + 视图 + 11 道题目
```

## 说明

- 课程实验项目，独立完成。
- 表结构与示例数据来自课程实验指导书给定的教学数据库实例。
