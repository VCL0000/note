


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
