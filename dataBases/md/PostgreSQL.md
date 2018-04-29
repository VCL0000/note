 vcl0000@vcl0000  ~/download  sudo dpkg -i postgresql-10.0-1-x64-bigsql.deb
[sudo] vcl0000 的密码：
正在选中未选择的软件包 postgresql10。
(正在读取数据库 ... 系统当前共安装有 362093 个文件和目录。)
正准备解包 postgresql-10.0-1-x64-bigsql.deb  ...
正在解包 postgresql10 (10.0-1) ...
正在设置 postgresql10 (10.0-1) ...

	======================================

	Binaries installed at: /opt/postgresql

	  sudo /opt/postgresql/pgc start pg10

	  sudo /opt/postgresql/pgc stop pg10
	  sudo /opt/postgresql/pgc restart  pg10


 vcl0000@vcl0000  ~/download   sudo /opt/postgresql/pgc start pg10

## Initializing pg10 #######################

Superuser Password [password]:
Confirm Password:
Setting directory and file permissions.
Creating the user postgres
$ useradd -m postgres



Initializing Postgres DB at:
   -D "/opt/postgresql/data/pg10"

Using PostgreSQL Port 5432

Password securely remembered in the file: /home/vcl0000/.pgpass

to load this postgres into your environment, source the env file:
    /opt/postgresql/pg10/pg10.env

pg10 config autostart /lib/systemd/system/postgresql10.service
$ mv /tmp/tmpRO4IOD.service /lib/systemd/system/postgresql10.service


$ systemctl enable postgresql10
Created symlink from /etc/systemd/system/multi-user.target.wants/postgresql10.service to /lib/systemd/system/postgresql10.service.


pg10 starting on port 5432
$ systemctl start postgresql10
----------------------------------------------------
passwrod 106514


python -c "$(curl -fsSL https://s3.amazonaws.com/pgcentral/install.py)"
cd bigsql
pgc install pg10
pgc start pg10

pgc install pgdevops
pgc init pgdevops
pgc start pgdevops

./pgc help


--------------------------------------------------------
pgc start pg10

## Initializing pg10 #######################

Superuser Password [password]:
Confirm Password:
Setting directory and file permissions.

Initializing Postgres DB at:
   -D "/usr/local/bin/bigsql/data/pg10"

Using PostgreSQL Port 5433
[Errno 13] Permission denied: '/home/vcl0000/.pgpass'
Traceback (most recent call last):
  File "/usr/local/bin/bigsql/pg10/init-pg10.py", line 197, in <module>
    pg_pass_file = util.remember_pgpassword(pg_password, str(i_port))
  File "/usr/local/bin/bigsql/hub/scripts/util.py", line 1601, in remember_pgpassword
    file = open(pw_file, 'w')
IOError: [Errno 13] Permission denied: '/home/vcl0000/.pgpass'
