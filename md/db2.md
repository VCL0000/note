


数据库层的命令

命令/SQL语句|描述
---|---
`db2 create database`|创建一个新的数据库
`db2 drop database`|删除一个数据库
`db2 connect to <database_name>`|连接数据库
`db2 create table/create view/create index`|分别创建表,视图,和索引的 SQL语句
`db2 "describe select * from [schema.table]"/db2 "describe table [schema.table]"`|查看表结构
`db2 describe data partitions for table schema.table show detail`|查看分区表分区 show detail 可以查看表空间信息
`db2look -d [dbName] -e -a -x -i [userName] -w [passWord] -o [DDLFile]`|导出表结构
`db2move [dbName] export -u [userName] -p [password]`|导出数据



## 数据迁移
### 导出
权限
SYSADM DBADM 或库表的 CONTROL SELECT
#### export
`export to users.del of del modified by coldel0x0f codepage=1208 messages message.log select * from test.user`
MODIFIED BY 字句指定定界符

选项|含义
-|-
chardel[x]|指定x作为新的单字符串分界符。默认值是双引号
coldel[x]|指定x对位新的单字符列分界符。默认值是逗号
codepage=[x]|指定x作为输出数据的新的码页。在导出操作期间，字符串被从应用程序码页转换成这种码页。加载时也指定这种码页，编码就好了
timestampformat="[x]"|源表中的时间戳的格式

导出包含大对象的列的表时，默认情况下只能导出LOB数据的前32KB
为了完整导出LOB，需要使用LOB选项，可以将LOB值连接起来导出到同一个输出文件中，也可以将每个LOB值导出到一个单独文件中。

#### db2move
只兼容IXF格式的文件，文件名由db2move自动生成
db2move sample export
db2move sample import

#### db2look
可以将DDL语句，数据库统计状态，表空间参数导出，这个导出可以用于不同系统的数据库
`db2look -d sample -l -e -o sample.ddl`
d databaseName,l layout(tablespaces & bufferpools),e DDL,t tableName,o outputFile

### 导入
权限
SYSADM DBADM 或库表的 SELECT INSERT CONTROL 或CREATETAB
#### import
可以导入到表，视图，但是不能导入到系统表，临时表。物化查询表

底层一般采用insert，涉及到日志记录 索引的更新 参照完整性检查 表约束检查。默认只在操作结束commit一次，COMMINTCOUNT 指定导入多少行数据后commit，AUTOMATIC 选项让import自己决定合适需要执行提交。
import 导入表的方式

选项|含义
-|-
INSERT|插入数据
INSERT_UPDATE|主键更新
REPLACE|将表中的数据全部删除
REPLACE_CREATE|目标表存在删除后插入，目标表不存创建表创建索引，然后导入。输入文件必须是PC/IXF格式的文件。如果目标表是被一个外键引用的一个父表，那么就不能使用。
CREATE|创建表和索引，然后导入数据，同时可以指定表空间。文件必须是PC/IXF格式。
`import from employee.ixf of ixf replace_create into employee_copy`


#### load
load 不会与db2数据引擎发生交互，不会触发触发器，不适用缓冲池，单独实现数据表的约束。
load 分为load build delete 三个阶段对硬盘上的数据页面直接进行处理。
`load from employee.ixf of ixf replace into employee_copy`
set integrity检查数据的一致性`SET INTEGRITY FOR employee_copy ALL IMMEDIATE UNCHECKED`



































end
