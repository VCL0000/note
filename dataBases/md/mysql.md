`sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf`
```
#bind-address           = 127.0.0.1
#lower_case_table_names=0
```
0--区分大小写;1--不区分大小写

`grant all on *.* to vcl0000@'%'` dba
