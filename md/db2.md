


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
`db2 grant control on table [schema.table] to user [userName]`|授权



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

## 备份升级相关

- 备份实例设置`db2support [path] -d sample -cl 0`备份当前实例和数据库配置信息，-cl 0 会手机数据库系统目录，数据库和实例配置参数，db2注册变量的配置等。
- 备份每个数据库的package信息`db2 list packages for all show detail > packages.file`
#### db2look
- 可以将DDL语句，数据库统计状态，表空间参数导出，这个导出可以用于不同系统的数据库
  - `db2look -d sample -l -e -o sample.ddl`
  - d databaseName,l layout(tablespaces & bufferpools),e DDL,t tableName,o outputFile，x生成用户权限相关的DDL,z schema

停止所有连接`db2 force applications all`
停止所有连接，停掉实例`db2stop force`

#### 升级
安装新版本->(检查是否可以升级)升级实例->升级库
`db2ckupgrade`检查是否可以成功升级。
在安装过的新版的../instance目录下执行
`./db2iupgrade -u db2fenc1 [instance]`
`db2 upgrade database sample`将库升级

`db2rbind dbname -l [file] all`重新绑定package

## 实例管理
#### db2 存储模型
表空间->容器->extent->page
page 4k 8k 16k 32k

`db2 get db cfg for [dbName]`获取数据配置

`db2 "create database [dbName] automatic storage yes on / dbauto dbpath on [databasePath] using codeset utf-8 territory cn collate using system"`

codeset 编码集，territory 区域。数据库一旦创建编码就无法改变。不指定9.5之后默认为utf-8。

创建数据库时，db2会创建三个默认的表空间，系统表空间（system tablespace）用来春初系统表，也就是数据字典的信息，一个数据库只能有一个系统表空间;临时表空间(temporary tablespace)用来保存语句执行时产生的中间临时数据，如join 排序等操作都会产生一些临时数据;用户表空间(user tablespace)用来存储表，索引，大对象等数据。
### 表空间
#### 创建表空间
- `db2 "create bufferpoll bp32k size 10000 pagesize 32k"`
- `db2 "create large tablespace [tbs_data] pagesize 32k managen by database using (file '/path/file 100M',file '/path/file2 100M') extentsize 32 prefetchsize automatic bufferpool bp32k no file system caching"`managed by datbase 表示空间的分配和管理由db2负责，即DMS；using 指定表空间的容器，DMS支持的容器类型是文件和裸设备；DMS类型的表空间在创建时即分配表空间，创建后可以对表空间容器就行增删改。数据建议用DMS管理
- `db2 "create temporary tablespace [tbs_temp] pagesize 32k managen by system using ('path/file') bufferpool bp32k"`系统临时表空间， managed by system 空间的分配和管理由操作系统负责，即SMS；SMS支持的容器类型只能是目录，并且无需指定大小，只要路径所属的文件系统有空间；SMS性能逼DMS差一些；临时表空间，建议用SMS管理。
- `db2 "create user temporary tablespace [tbs_user_temp] pagesize 32k managed by system using ('path/file') bufferpool bp32k"`，用户临时表空间。
- `db2 "create tablespace [tbs_index] pagesize 32k bufferpool bp32k"`，自动存储管理表空间（automatic storage）无需指定容器类型和大小，实际上底层任然是DMS SMS，只是容器不需要指定；自动存储表空间的数据在建库时指定的 ON目录；只有建库时启用了 automatic storage yes，表空间才支持自动存储管理。
- `db2 "create tablespace [tbs_data2] initialsize 100M increasesize 100m maxsize 1000G"`

#### 更改表空间
- 若表空间容器对应的存储中还有未分配空间，可以通过 alter tablespace的extend 或resize选项扩展已有表空间容器的大小,`db2 "alter tavlespace [data_ts2] extend (file 'path/file' 10M,file 'path/file1' 50G)"`,在每个容器上扩展50GB。
- 表空间容器对应的存储中没有剩余空间时，可以通过alter tablespace 的 add 选项增加新的容器。add增加的容器会在容器间进行数据 rebalance(数据重新平衡)数据大的话rebalance时间回比较长。`db2 "alter tablespace [data_ts2] add (file 'path/file' 50G)"`
- alter tablespace begin new stripe set,已有容器使用完后新增家容器。不会rebalance，但会造成数据偏移，`db2 "alter tablespace [data_ts2] begin new stripe set (file 'path/file' 10M)"`
- 自动存储管理的表空间，无法在表空间级进行容器更改，只能在数据库级别，自动存储路径实在建库是指定的。可以通过 add storage on 选项为数据库添加新的存储路径。`db2 alter database [dbName] add storage on [dbpath]`
- 只要对自动存储表空间执行了rebalance操作，就可以立即使用这个存储路径，不用等到存储路径文件系统空间满了。
- 更该容器管理类型，DMS向自动存储路径迁移数据是要话花费一些时间做数据重新平衡操作，`db2alter tablespace [ts4] managed by automatic storage`，`db2 alter tablespace [ts4] rebalance`.

#### 表空间状态

- quiesced,表空间只读`db2 quiesce tablespaces for tale [schema.table] share`,`db2 quiesce tablespaces for tale [schema.table] reset`
- backup pending,归档日志模式下，表空间前滚/load ... copy no,表空间处于该状态
- drop pending,重启数据库时，如果一个或多个容器有问题，表空间不再可用。

#### 表空间信息
- 获取表空间信息，`db2 get snapshot for tablespaces on sample `
- 表空间的配置信息，使用情况和容器信息`db2pd -d sample tablespaces`
- 查看表空间，`db2 list tablespaces show detail `/`db2 list tablespace containers for [tablespaceId] show detail`
- 更加详细的表空间信息，`db2 get snapshot for tablespaces on [dbName]`

SMS表空间无法通过命令监视，只受文件系统限制。

#### 表空间高水位
- HWM,DMS表空间的属性，代表表空间当前分配的最高页数，这个值Kenneth大于已经使用的页数（userd pages）
- alter tablespace 的 reduce resize drop 选项对表空间进行更改时，如果更改后的页数小于HWM的值，操作将会失败。
- db2dart 的 DHWM选项显示HWM相关信息，`db2dart sample /DHWM`
  - LHWM选项提供降低HWM的建议和方法，`db2dart sample /LHWM`，如重组（reorg），数据导出加载（export/load），删除重建（export/drop/create/load）。表在离线重组（reorg）时会保留原数据，同时在表空间内进行一份数据复制，当复制结束后删除原表数据块，如果没有足够的空间保存数据复制，HWM反而会增加。
  - RHWM,删除占据HWM的空SMP块。SMP块用来标识该块映射的一组extents是否可用，如果一个空SMP占据了HWM，可以来降低`db2dart sample /RHWM`。
  - 9.7之后创建的DMS表空间可以通过alter tablespaces 降低HWM，`db2 alter tablespace [data_ts1] reduce MAX`


### 备份
#### 离线备份
- 断开连接，关闭数据库，`db2stop force`
- 启动数据库,`db2start`
- 显示所有数据及其路径列表，`db2 list database directory`
- 显示所有活动的数据，`db2 list activce databases`
- 失效数据库实例,`db2 deactivate database [sample]`
- 数据库的备份和恢复，不能跨平台恢复。离线备份,`db2 backup database [sample] to [path]`
- 恢复到相同数据库`db2 restore database [sample] from [path]`
-恢复到不同数据库,`db2 restore database [sample] from [path] into [otherDatabase]`
- `db2 list history backup all for [sample]`,查看备份记录

#### 在线备份
- 显示配置信息,`db2 get db cfg for [sample]`
- 启用日志归档模式,`db2 update db cfg for [sample] using LOGRETAIN ON`
- 设置日志归档目录,`db2 update db cfg for [sample] using LOGARCHMETH1 DISK:[path]`
- 做一次离线备份，否则数据库会登录不了[如果提示有连接无法备份，请参考db2离线备份],`db2 backup db [sample] to [path]`
- 在线备份--备份日志（首个活动日志到当前日志会一同备份到备份文件里）,`db2 backup db [sample] online to [path] include logs`
- 从包含日志的备份集恢复(恢复同一个数据库 into [sample] 可省略)。要导入的数据库的归档目录不要和备份恢复的日志目录相同。`db2 force applications all`,`db2 RESTORE db [sample] FROM [backupPath] taken at 20130618142149 into [sample] LOGTARGET [logPath]`
- 前滚。由于从备份成功到数据库崩溃的时间间隔会产生其他的归档日志，可以将这些日志拷贝到/data/db2data/logs/中，或者直接从归档日志目录进行前滚，同"从不包含日志的备份集恢复"中的"前滚"。`db2 "rollforward db [sample] to end of logs and stop overflow log path([logPath])"`

## 数据对象
### 模式
`create schema [schemaName]`,显示创建，隐式创建是在建表的时候指定。
`syscat.schemata`,查看数据数据库创建了哪些模式
相关系统模式
- `SYSIBM`，模式下的对象存储的是系统数据字典表
- `SYSCAT`，模式下的对象是系统视图，可通过查看这些视图查看各种数据对象信息。
- `SYSIBMADM`，系统管理视图模式
- `SYSSTAT`，统计视图模式，有9个视图，用来为db2优化器提供统计信息
### 表
`db2 describe table [schema.table]`,查看表字段及数据类型
`db2 list tables for schema [schemaName]`,查看某个模式下的表名视图和alias别名。
`db2 list tables for all`,查看所有模式下的表名视图和alias别名
`db2 list tables`，查看以当前连接用户作为模式名下的表名等。
通过`SYSCAT.TABLES`系统视图查看表定义，所属表空间等。`SELECT SUBSTR(TABSCHEMA,1,32) AS TABSCHEMA,SUBSTR(TABNAME,1,32) AS TABNAME,TBSPACEID FROM SYSCAT.TABLES WHERE TABSCHEMA='[TEST]'`
### 表约束

- 非空约束not null,唯一性约束unique,主键约束primary key,外键约束foreign key,检查约束check（检查约束如同枚举）。
- `alter table [tableName] add constraint [PKName] primary key([columnName])`
- `alter table [tableName] add unique[columnName]`
- `alter table [tableName] add constraint [Name] check ([column] in ('A','B','C'))`

- 通过系统视图查看数据库中定义的约束，`SELECT SUBSTR( CONSTNAME, 1, 18 ) AS CONSTNAME, SUBSTR( TABNAME, 1, 18 ) AS TABNAME, SUBSTR( FK_COLNAMES, 1, 14 ) AS FK_COLNAMES, SUBSTR( REFTABSCHEMA, 1, 14 ) AS REF_SCHEMA, SUBSTR( REFTABNAME, 1, 14 ) AS REF_TABNANE, SUBSTR( PK_COLNAMES, 1, 14 ) AS K_COLNAMES, DELETERULE FROM SYSCAT.REFERENCES WHERE TABSCHEMA = 'TEST'`
- 通过`syscat.checks`视图查看数据中定义的检查约束，`SELECT TABNAME,SUBSTR(TEXT,1,500) FROM SYSCAT.CHECKS`

- 删除约束，`alter table [tableName] drop constraint [constName]`

### 表状态


































end
