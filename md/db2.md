


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


## 升级相关

- 备份实例设置`db2support [path] -d sample -cl 0`备份当前实例和数据库配置信息，-cl 0 会收集数据库系统目录，数据库和实例配置参数，db2注册变量的配置等。
- 备份每个数据库的package信息`db2 list packages for all show detail > packages.file`
#### db2look
- 可以将DDL语句，数据库统计状态，表空间参数导出，这个导出可以用于不同系统的数据库
  - `db2look -d sample -l -e -o sample.ddl`

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
执行一些操作时，表可能处于某种状态，如load可能导致表处于 laod pending，not restartable等，对表结构进行更改时，也可能导致表状态异常。alter table可能会导致表处于reorg-pending状态。
### 表压缩
表压缩可以减少存储空间，也节省I/O和内存占用，但是压缩和解压缩需要一定的CPU资源。
`alter table [tableName] compress yes`，`db2 reorg table [tableName]`,查看表使用空间`SELECT SUBSTR(TABNAME,1,32) AS TABNAME,DATA_OBJECT_L_SIZE,DATA_OBJECT_P_SIZE,DICTIONARY_SIZE FROM SYSIBMADM.ADMINTABINFO WHERE TABNAME='USER';`
### 表分区
ing...
### 索引
通过索引获取RID，找到对应的页面和偏移位置，从而找到数据，无需扫全表。
`creata index [idxName] on [table] ([column])`,普通索引
`creata unique index [idxName] on [table] ([column])`,唯一索引
`creata index [idxName] on [table] ([column]) cluster`,cluster选项表示集群或簇的意思，目的是尽量保持数据页的物理顺序和索引键顺序保持一致。默认情况下表数据的五路组织是无序的，如果数据在物理上是连续的，这时获取数据需要的页数就更少了。对根据返回获取一组数据是cluster索引可能带来I/O效率的巨大提升。(数据的增删改可能会造成数据物理顺序无法和索引键保持一致，可以通过reorg对表和索引进行重组)
`creata unique index [idxName] on [table] ([column]) include ([column1],[coumn2])`，include字段会附加在索引键指向的每个RID上，这样就可以从索引中直接获取include字段。include也叫index-only，只有唯一索引才可以使用。
`create index [idxName] on [table] ([column1],[column2])`,复合索引。

查看索引的相关信息,`db2 describe indexes for table [schema] show detail`,也可以通过`syscat.indexes`查看索引信息。

### 视图
`creata view [viewName] ([column]) as [子查询]`。
`syscat.views`视图相关信息，包括视图定义。

### identity
`generated always as identity`,系统自增,不允许插入
`generated by default as identity`,用户指定，允许插入

### 大对象
循环日志LOB字段更改不记日志，归档日志可以选择不记日志。


## 数据迁移
export,import,load,db2look,db2move,db2dart

文件格式|工具|-
-|-|-
DEL,IXF,WSF|export|->
DEL,IXF,WSF,ASC|import|<-
DEL,IXF,ASC,CURSOR|load|<-
IXF|db2move|<->
DEL|db2dart|->

DEL(ASCII数据使用分隔符) ASC(定长ASCII) 是文本格式，IXF IBM二进制，WSF新版本不支持，sursor(游标)

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
`commitcount [N/automatic]`,避免事务日志满和锁升级。`commitcount automatic` ,import命令自动选择合适提交，默认会自动使用automatic选项
`allow write access`，允许其他应用读写。
`import from xx.del of del allow write access commitcount automatic insert into [table]`
`restartcount/skipcount N`,表示跳过文件前N行数据，从N+1开始继续导入。

#### load

- load 不会与db2数据引擎发生交互，不会触发触发器，不适用缓冲池，单独实现数据表的约束。 load 可以使文件或游标
- load 分为load,build,delete,index copy
   - laod 不符合表定义的数据不会被装载到表中，但可以放到转储文件（dump file），并记录在message消息文件中，`modified by dumpfile`指定转储文件。
   - build 基于装载阶段收集到的键创建索引
   - delete 将违反唯一约束的行删除，but不会检查 check 和参照完整性约束，可以创建异常（exception table）表来转储被删除的行，灭有指定异常表，重复数据将会被删除。
   - index copy，指定了`allow read access`，`use tablespace`,会将索引数据从系统临时表空间中复制到索引表空间中。
   - 异常表需要事先创建，并且在原表基础上增加两个列，被插入的时间戳，被党组异常原因的ClOB列。`create table [empexpTable] like [tableName]`，`alter table [empexpTaable] addcolumn ts timestamp add column msg clob (32k)`。
- `LOAD FROM input_source OF input_typemessafe message_file [INSERT|REPLACE|TERMINATE|RESTART] INTO target_tablename`
   - insert 追加不改变表中已有数据；repacle首先删除表数据，然后插入输入文件数据；terminate将终止load操作，并将数据恢复到load开始时的状态，如果load replace 时出现了 load pending,采用load ... terminate 会清空表；restart 重启被终端的load，restart会使用之前load时产生的临时文件，并从最近的一点开始加载，临时文件默认实在当前的工作目录中创建，`TEMPFILES PATH`选项制定存档临时文件的目录。
   - load `allow no access`选项在load完成之前不允许其它应用访问该表，此为默认。
   - `allow readaccess`选项，load时允许其它应用访问load之前的原有数据，但是不能访问新加载的数据。load... replace不支持该选项。
   - `load query`检查表状态，`db2 load query table test.user`
   - copy选项，只适用与归档日志，循环日志没有意义。
     - copy no, copy yes,nonrecoverable。
     - copy no是默认方式，会将load表所在表空间置于backup pending状态，需要在load后对表空间做备份，目标表可读，但不能进行增删改，终止load表也不会脱离该状态。
     - copy yes 会在load结束时自动对表所属的表空间做一次备份。前滚恢复时，db2会使用这个备份文件恢复load过程中加载的数据。
     - nonrecoverable,会将表标记为不可恢复。若恢复表空间，并且回滚到nonrecoveravle load选项之后的某个时间点，这个表是不可恢复的，所有相关日志会被忽略，只能删除并重建表。
- 从游标load数据，`declare my_cursor cursor for select * from test.user`，`load from my_cursor of cursor insert into test.user2`
- load delete阶段只会删除违反唯一约束的行，表中包含参照完整性约束和检查约束的的数据，laod不会检查这些数据，而是将表置于`set integrity pending`状态，访问时会报57016。解除这种状态需要通过`set integrity`检查数据完整性。
  - OFF，将检查关闭，同时将表处于`set integrity pending`状态
  - IMMEDIATE CHECKED，对表立即做完整性检查，从`set integrity pending`中脱离，主表脱离时，依赖表可能会处于此状态。
  - IMMEDIATE UNCHECKED，不对表做检查，但将表从`set integrity pending`脱离。
  - `set integrity pending`状态下的表如果包含异常数据，则必须创建异常表，才能使表脱离此状态。
  - `SET INTEGRITY FOR employee_copy ALL IMMEDIATE UNCHECKED`
  - `set integrity for  [schema.table] immediate checkedforexception in [tableName] use [expTanleName]`
  - `SELECT TABNAME,STATUS,ACCESS_MODE,SUBSTR(CONST_CHECKED,1,1) AS FK_CHECKED,SUBSTR(CONST_CHECKED,2,1) AS CC_CHECKED FROM SYSCAT.TABLES WHERE STATUS='C';`,检查表的状态，是否允许访问及表的主外键约束，约束检查等。
- `load from xx.del of del modified by coldel0x0f codepage=1208 meessages xx.msg replace into [tableName] nonrecoverable`

#### db2move
只兼容IXF格式的文件，文件名由db2move自动生成
`db2move sample export`,db2move.list存放导出的表和对应的导出数据以及消息文件列表，EXPOTRT.out 存放导出过程，tabx.ixf 数据文件，tabx.msg消息文件。
`db2move sample import`

#### db2look
- 可以将DDL语句，数据库统计状态，表空间参数导出，这个导出可以用于不同系统的数据库
  - `db2look -d sample -l -e -o sample.ddl`
  - d databaseName,l layout(tablespaces & bufferpools),e DDL,t tableName,o outputFile，x生成用户权限相关的DDL,z schema

### db2dart
事务日志被破坏，磁盘故障，且没有数据库备份的情况下，只有db2dart了
不会抽取大对象数据。db2dart导出的数据文件可以通过load/import加载。db2dart的时候最好deactivate数据库否则可能会出现不一致。
`db2dart sample /ddel`，会让输入表ID 表空间ID，`/rpt`选项可以指定导出数据文件位置。
`db2dart /db`,选项会检查数据库完整性，对数据库中的每张表进行检查，输出表名，表ID，表空间ID。

## 备份恢复

- db2恢复的类型：版本恢复（恢复到上次备份，上次备份之后的丢失），前滚恢复（在版本恢复的基础上，使用日志，恢复到奔溃前），崩溃恢复（一个事务两个sql，第一个执行完崩溃了，事务被中断，数据库处于不一致状态。系统重启时会回滚（undo）没有提交的数据，重做（redo）已经提交但是没有写入磁盘的数据，将数据库恢复到一致状态。缺省情况崩溃恢复是自动执行的。）

### 日志
- `db2 get db cfg for sample |grep -i log`，数据日志参数。
- 日志空间，由logprimary（主日志文件个数），logsecond（辅助日志文件个数），logfilsiz（每个日志文件的页数）。日志空间的最大限制等于(logprimary+logsecond)*logfilsiz*4K。
- 日志文件位于`NEWLOGPATH`,可以通过`MIRRORLOGPATH`参数设置日志镜像路径。
- 日志模式：归档日志，循环日志。`LOGARCHMETH1`为OFF表示循环日志，OFF以外的值为归档日志。循环日志是创建数据库时的默认模式，当更改为归档日志时，需要做离线全备，飞则连接时会`backup-pending`

### 备份
backup online(在线备份，日志模式需要是归档日志) tablespace(指定对某些表空间备份，归档模式可用) incremental(指定增量备份，最近一次全备以来的变化数据备份，incremental delta 备份是最近次备份 任何类型的备份以来变化数据库的备份) compress(压缩备份介质) include logs(只适用于在线备份，备份完成时将但前活动日志归档，并将其导报到备份介质中)

#### 离线备份
- 断开连接，关闭数据库，`db2stop force`，显示所有数据及其路径列表，`db2 list database directory`，显示所有活动的数据，`db2 list activce databases`，失效数据库实例,`db2 deactivate database [sample]`。
- 数据库的备份和恢复，不能跨平台恢复。离线备份,`db2 backup db [sample] to [path]`

#### 在线备份
- 启用日志归档模式,`db2 update db cfg for [sample] using LOGRETAIN ON`,设置日志归档目录,`db2 update db cfg for [sample] using LOGARCHMETH1 DISK:[path]`,做一次离线备份，否则数据库会登录不了[如果提示有连接无法备份，请参考db2离线备份],`db2 backup db [sample] to [path]`。
- 在线备份,`db2 backup db [sample] online to [path] include logs`，从开始备份到结束备份期间的操作记录到日志中，includ logs 选项会关闭当前活动的日志，并进行归档，然后打包存到备份介质中。
#### 表空间备份
`backup db <db> tablespace (<tabs1>[,tabs2]) online  [to <path>]`
#### 增量备份
积累增量，每次都在上次全备基础上备份；迭代增量，每次都在上次备份基础上备份。
`backup db <db> [tablesapce (<tabs1>[,tabs2])] [online] incremental [delta] [to <path>]`
#### 备份介质检查
SAMPLE.0.DB2.NODE0000/CATN0000.20110415102710.001
数据名.备份类型.实例名.分区节点号.编目节点号.备份时间戳.顺序号
备份类型：0-全备;3-备份表空间;4-load copy备份。但分区接单号固定为NODE0000，编目节点号固定为CATN0000,时间戳为备份开始的时间
`db2ckbkp -h file`，检查备份,-a检查需要前滚的日志文件。
`db2 list utilities show detail`,备份执行中情况

### 恢复

- 恢复到相同数据库，`db2 restore db [sample] from [path] taken at [时间戳]`，taken at确定恢复哪个备份文件。
-恢复到不同数据库,`db2 restore db [sample] from [path] into [otherDatabase]`
- `db2 list history backup all for [sample]`,查看备份记录
- 从包含日志的备份集恢复(恢复同一个数据库 into [sample] 可省略)。要导入的数据库的归档目录不要和备份恢复的日志目录相同。`db2 RESTORE db [sample] FROM [backupPath] taken at [备份时间戳] into [sample] LOGTARGET [logPath]`,logtarget 将日志恢复到一个指定的目录。
- 前滚。由于从备份成功到数据库崩溃的时间间隔会产生其他的归档日志，可以将这些日志拷贝到/data/db2data/logs/中，或者直接从归档日志目录进行前滚，同"从不包含日志的备份集恢复"中的"前滚"。`db2 "rollforward db [sample] to end of logs and stop overflow log path([logPath])"`，`overflow log path 指定前滚获取日志的目标`


## 运维
runstats(收集统计信息，为db2优化器提供最佳路径选择),reorgchk(重组前检查),reorg(重组，减少表和索引在五路存储上的碎片),rebind(对包，存储过程，或者静态程序进行重新绑定)

### runtatus
- `runstatus on table <schema>.<tableName> on all columns with distribution and detailed indexes all`,收集统计信息，包括数据分布。
- `runstatus on table <schema>.<tableName> for indexes all`,收集索引统计信息，如果表上没有统计信息，会同时对表做统计，但是不会收集数据分布信息。
- `runstatus on table <schema>.<tableName> tablesample bernoulli(10)`,(伯努利10%抽样统计)使用伯努利算法抽样统计，扫描每一行数据，但是只对一定比例抽样数据进行统计，适用于大表，大表的全表统计比较消耗资源。
- `select char(tabname,20) as tabname,stats_time from syscat.tables where stats_time is null`,stats_time 字段为空值表明没有收集过统计信息，否则会显示统计信息的时间。
- `reorgchk update statistics`对所有表收集统计信息，但是不会收集分布统计。
- runstats:allow write access,runstatus时其它应用可以读取和修改，默认行为;allow read access，只能读取无法修改。
### reorg
- 数据夸页，甚至有些页为空页，数据不连续。
- `db2 reorgchk on schema <schemaName>`,如果输出中F1，F2，F3标记为*则需要reorg；如果索引统计结果F4-F8有*，则需要对索引reorg。
- 离线reorg，支持allow read access (默认),allow no access。离线reorg采用影子拷贝方法。离线索引可以通过`index index-name`选项指定根据哪个索引进行重组，如果定义了聚集索引即使灭有指定索引，默认也会按照聚集索引重组表。reorg分为四个阶段
 - scan-sort,根据reorg指定的索引对表数据进行扫描，排序。
 - build，根据第一阶段结果进行构建
 - replace(copy)，用新数据替换原有数据
 - index rebuild，基于新数据重建索引。
- `db2 get snapshot for tables on <sample>`,进行reorg监控。
- `db2pd -d <sample> -reorg`获取当前正在执行的和近期完成的重组信息。`db2 list history reorg all for <sample>`,获取表或索引重组信息。
- 在线reorg(inplace reorg)，在原空间中进行，表数据重组是分批次的，比离线reorg慢的多，会记录大量的日志，可能是表大小的几倍。
  - 支持 allow read access,allow wrute access(默认)
  - `db2 reorg table <schema>.<table> inplace allow write access`,在线reorg。
- reorg 索引，`db2 reorg indexes all for table <table>`

### rebind
C程序中的sql预编译后会把执行计划被放到package中，but新添加索引等后执行计划不会更新。
`db2 list packages for schema <schema>`,列出相应的package名
rebind只能针对每个package，`db2rbind sample -l db2rbind.log all`,对所有package重新绑定。动态SQL是执行时才编译的，存储在 package cache中，统计信息更新后，可以通过`flush package cache dynamic`，更新package cache。

### 表空间大小
`db2 "call get_dbsize_info(?,?,?,<refresh-window>)"`refresh-window，为输入参数，进行数据大小和容量大小的刷新，单位为分钟，默认30，传入0会立即刷新。
`db2 list tablespaces show detail`,`sysibmadm.tbsp_utilization`也可以查询表空间使用率。
计算某个表占用空间有`db2pd -tcbstats`,`admin_get_tab_info`,`SYSIBMADM.ADMINTABINFO`。三种方法
  - `db2pd -d <sample> -tcbstats`,DataSize表示表的页数。
  - `describe table SYSIBMADM.ADMINTABINFO`


## 监控
分为两类，实时监控和追踪监控。实时监控记录数据库某一时刻的快照信息shapshot db2pd db2top；实时监控提供跟详细的数据活动,事件监控器和 activity monitor,事件监听器可能会产生较大的数据量，对系统造成较大的影响，一般用于问题诊断。
### snapshot
监控元素分为以下几类
- 计数器(counter):用来村粗累计值，比如实例启动依赖数据库发生的总排序次数(total sorts)，死锁个数(deadlocks)，读取行数(rows read)等
- 计量/瞬时值(gauge):记录某个监控元素的当前值，比如当前发生排序的次数(active sorts)，当前的锁个数(locks)。
- 高水位值(high water mark):记录一个监控元素在打开监控开关以阿里所达到的最大值或最小值，通过高水位值可以获取峰值时的数据。
实际分析中需要进行多次抓取快照，分析一段时间内的数据库活动。
`db2 get snapshot for database on <sample>`
`db2 get snapshot for applications on <sample>`
`db2 get snapshot for tables on <sample>`
`db2 get snapshot for tablespaces on <sample>`
`db2 get snapshot for locks on <sample>`
`db2 get snapshot for bufferpools on <sample>`
`db2 get snapshot for dynamic on <sample>`

### db2pd
速度快，性能好。
分区数据库中存在多个物理节点时，必须运行在逻辑分区所在的物理节点。如果分区在远程物理节点，可以使用-global参数运行，`db2pd -db sample -dbp 3 global`

- `db2pad -db sample -appl`,应用程序。
- `db2pd -edus`,输出EDU列表，cpu相关。
- `db2pd -osinfo`,操作系统信息。
- `db2pd -db <sample> -bufferpool`,缓冲池信息。
- `db2pd -db <sample> -logs`,日志信息。
- `db2pd -db <sample> -tablespaces`,表空间信息。
- `db2pd -db <sample> -locks`,锁信息。
- `db2pd -db <sample> -agents`,代理信息。
- `db2pd -db <sample> -static`,静态语句。
- `db2pd -db <sample> -dynamic`,动态SQL信息。
- `db2pd -db <sample> -tcbstats`,表状态信息。
- `db2pd -db <sample> -tcbstats index`,索引信息。

### db2top
原理是在后台每隔一段时间收集一次快照，探后通过计算其与最近一次快照之间的数值差别与经过的时间，计算出一些列统计数据。
`db2top -d <sample>`，进入交互界面，h帮助菜单。
`/`进行搜索，!xx不包含xx的。`z`按照列进行排序，列序号从0开始。`L`输入第一列的hash值，查看SQL。`x`得到当前语句的执行计划（需要创建sqllib/misc/EXPLAN.DDL中的表）,`l`系统中应用程序列表，`b`缓冲池，主要监控命中率和逻辑物理读取的数量，`U`锁，`T`表。
历史信息收集

- `db2top -d <sample> -f <out.file> -C -m 480 -i 15`,m指定收集模式运行多少分钟，i指定隔多少秒收集一次快照。
- `db2top -d <sample> -f <out.file> -b 1 -A`,重新播放收集到的数据，`db2top -d <sample> -f <out.file> /02:00:00`直接查看给定时间戳时的信息。

### 事件监控器
当谋个事件发生时记录信息的机制，比如发生死锁时，会将死锁先关的信息写到表或文件中，便于事后分析。事件监控器产生的数据量比较大，会对系统造成非常大的影响。
`create event monitor`,创建监控器，监控器创建后不会自动启动，`SET event_moitor_name STATUS=1`来激活，如果把记过输出到文件系统，可以通过db2evmon解析数据`db2evmon -path > even_monitor_target`
## 优化器与性能调优
`db2exfmt`生成文本访问计划
`db2 -tvf ~/sqllib/misc/EXPLAIN.DDL`，创建执行计划需要的表。运行`db2 set current explain mode explain`,打开访执行计划选项，按照普通普通方式SQL，然后使用`db2 set current explain mode on`，关闭访问计划选项。`db2exfmt -d <sample> -g TIC -w -l -n % -s % -# 0 -o <file>`
`explain -d <sample> -f <select.sql> -g -t`,-q "",输入参数，-o 结果输出到文件。
`db2advis -d <sample> -i <select.sql> -t 5`,优化建议，-n指定schema， -a uaername/passwd,指定用户密码。
### 索引
`db2pd -d <sample> -tcbstats -index`,输出有个scans，一段时间内为0说明索引没有用到。也提供MON_GET_INDEX视图用来识别没有用到的索引。  
`SELECT SUBSTR(T.TABSCHEMA,1,18),SUBSTR(T.TABNAME,1,18),SUBSTR(S.INDSCHEMA,1,18),SUBSTR(S.INDNAME,1,18),T.PAGE_ALLOCATIONS,S.UNIQUERULE,S.INDEXTYPE FROM TABLE(MON_GET_INDEX('','',-1)) AS T,SYSCAT.INDEXES AS S WHERE T.TABSCHEMA= S.TABSCHEMA AND T.TABNAME=S.TABNAME AND T.IID=S.IID AND T.INDEX_SCANS=0`


























end
