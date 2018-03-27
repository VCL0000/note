[TOC]

# Linux Note
*大部分内容只适用于Linux,UNIX在如配置文件的位置内容，命令的名称有些许差异*

## shell

### 默认的交互shell和默认的系统shell，是不一样的含义
### 登录shell

- /etc/profile文件是bash shell默认的的主启动文件。只要登录了Linux系统，bash就会执行/etc/profile启动文件中的命令
- profile会迭代/etc/profile.d目录下的所有文件。
登录Linux系统时，bash shell会作为登录shell启动。登录shell会从5个不同的启动文件里读取命令：
 - /etc/profile
 - $HOME/.bash_profile
 - $HOME/.bashrc
 - $HOME/.bash_login
 - $HOME/.profile

- shell会按照按照下列顺序，运行第一个被找到的文件，余下的则被忽略：
 - $HOME/.bash_profile
 - $HOME/.bash_login
 - $HOME/.profile

- .bash_profile启动文件会先去检查HOME目录中是不是还有一个叫.bashrc的启动文件。

### 交互式shell
它就不会访问/etc/profile文件，只会检查用户HOME目录中的.bashrc文件。

###非交互式shell
执行shell脚本时用的就是这种shell。
bash shell提供了BASH_ENV环境变量，shell会检查这个环境变量来查看要执行的启动文件。如果BASH_ENV变量没有设置，子shell可以继承父shell导出过的变量，由父shell设置但并未导出的变量都是局部变量。子shell无法继承局部变量。对于那些不启动子shell的脚本，变量已经存在于当前shell中了。所以就算没有设置BASH_ENV，也可以使用当前shell的局部变量和全局变量。

### shell命令历史
**bash shell会跟踪用过的命令**

`history` 最近用过的命令列表
`.bash_history`   命令历史的存放位置
`!!`  上次使用的命令
`!n`  编号为n的历史命令
`history -a`  强制写入命令历史文件

### 命令别名
`alias -p`    查看当前可用的别名
`alias li='ls -li'` 创建别名格式

### 协程
协程可以同时做两件事。它在后台生成一个子shell，并在这个子shell中执行命令。
`coproc commond`
`coproc job_name { commond; }`
commond和{}之间要有空格 协程的名字用于多个协程之间通信

### 命令分组
`(commond;commond...)` 会启动子进程
`{commond;comond...}` 不会启动子进程
- $BASH_SUBSHELL 返回0，就表明没有子shell。如果返回1或者其他更大的数字，就表明存在子shell。
- 子进程并非真正的多线程，终端控制着子进程的I/O

### 环境变量
* 查看全局环境变量
  * env | printenv
* 显示为某个特定进程设置的所有环境变量,包括局部变量、全局变量以及用户定义变量。
  * set
* 设定全局环境变量的进程所创建的子进程中，该变量都是可见的
  * export xx="xx"


### **环境变量持久化**

* 全局环境变量（Linux系统中所有用户都需要使用的变量），放在/etc/profile文件中，但这是危险的，（发行版更新会覆盖）最好是在/etc/profile.d目录中创建一个以.sh结尾的文件。把所有新的或修改过的全局环境变量设置放在这个文件中。
* 存储个人用户永久性bash shell变量的地方是$HOME/.bashrc文件。这一点适用于所有类型的shell进程。
* 但如果设置了BASH_ENV变量，除非它指向的是$HOME/.bashrc，否则你应该将非交互式shell的用户变量放在别的地方。

### basename 命令返回不包含路径的脚本名
`shell_script_name=${basename $0}`

## commond 基础

### 查看命令的所在位置
`which commond`
`type -a commond`
`whereis  commond`
`locate commond`
* type 会列出shell内建和外部命令；which只会给出外部命令
* 内建命令是编译在shell中的不会开启子进程来执行外部命令；执行外部命令shell会开启子shell来执行外部命令
* whereis 会给出程序的安装路径
* locate 给出系统中相关的位置


### cut
cut 命令从它的输入行中选出若干部分,再打印出来。该命令最常见的用法是提取被限定的若干域,能返回由列边界所限定的若干区段。默认的限定符是Tab
-d 选项改变这个限定符
-f 选项指定输出里包括哪些域
`cut -d: -f7 < /etc/passwd`

### sort

选项|含义
---|---
-b|忽略开头的空白
-f|排序不区分大小写
-k|指定构成排序关键字的列
-n|按整数值比较域[译者注:即按数值排序]
-r|颠倒排序的顺序[译者注:即逆序]
-t|设定域分隔符(默认的分隔符是空白)
-u|只输出唯一记录[译者注:重复的记录只输出一次]\\排序的group by
`
ps -ef | sort -k2,2 -n
sort -t: -k3,3 -n /etc/group
`


????? uniq 按某列排序
### uniq
重复行只打印一次//group by 加count
uniq 命令在思想上和 sort -u 类似,但它有一些 sort 不能模拟的选项
uniq 命令的输入必须先排好序,因此通常把它放在 sort 命令之后运行。

选项|含义
---|---
-c|累计每行出现的次数
-d|只显示重复行
-u|只显示不重复的行

`cut -d: -f7 /etc/passwd | uniq -c | sort -k1,1 -n`

### wc
默认为 l w c
```
-l 行数
-c 字节数
-w world数
```

### tee
把输入复制到两个地方
命令的管道一般都是线性的,但是从中间插入管道里的数据流,然后把一份副本发送到一个文件里,或者送到终端窗口上,也往往会很有帮助。用 tee 命令就能做到这一点,该命令把自己的标准输入既发送到标准输出,又发送到在命令行上指定的一个文件里。可以把它想成是水管上接的一个三通。
设备/dev/tty 是当前终端的同义语。
将输出给两个地方
`find / -name core | tee /dev/tty | wc -l`

### grep
选项|含义
---|---
-c|打印匹配行数的
-i|匹配时忽略大小写
-v|打印不匹配行(而不是匹配行)
-l|它让 grep 只打印匹配文件的名字,而不是匹配的每一行
-s|不输出错误
`sudo grep -l mdadm /var/log/*`

### sed
一些 sed 命令
`sed 's/string1/string2/g'`替换 string1 为 string2
`sed -i 's/wroong/wrong/g' *.txt`用 g 替换所有返回的单词
`sed 's/\(.*\)1/\12/g'`修改 anystring1 为 anystring2
`sed '/<p>/,/<\/p>/d' t.xhtml`删除以 <p> 开始,以 </p> 结尾的行
`sed '/ *#/d; /^ *$/d'`删除注释和空行
`sed 's/[ \t]*$//'`删除行尾空格 (使用 tab 代替 \t)
`sed 's/^[ \t]*//;s/[ \t]*$//'`删除行头尾空格
`sed 's/[^*]/[&]/'`括住首字符 [] top -> [t]op
`sed = file | sed 'N;s/\n/\t/' > file.num` 为文件添加行号

### rar
解压
`rar e xx.rar`

### 碎碎念
- `cp -p` 保留文件的属性
- `time commond` 命令运行的时间
- `watch uptime` 以周期性的方式执行给定的指令
- `time cat` 秒表一样
- `cal -3`显示最近三个月日历
- `cal xx xxxx`显示xxxx年xx月的日历
- `mkdir -p /xx/xx/xx`如果存在不显示错误,不存在创建目录
- `rmdir xx/xx/yy`移除目录yy
- `cp test.sh{,.pl}`复制为新的扩展名
- `mv test.sh{,.pl}`修改为新的扩展名
- `echo 'Test' | tr '[:lower:]' '[:upper:]'`转换成大写
- `rename .cxx .cpp *.cxx` 重命名所有 .cxx 成 .cpp
- `:(){ :|:& };:` bash fork 炸弹,迅速耗尽系统所有资源,本质是函数的递归调用


## Commond About

### 挂载媒体设备
**mount -t type device directory**
Example：手动将U盘/dev/sdb1挂载到/media/disk
`mount -t vfat /dev/sdb1 /media/disk`


### 卸载 设备文件
**umount [directory | device ]**
如果在卸载设备时，系统提示设备繁忙，无法卸载设备，通常是有进程还在访问该设备或使用该设备上的文件。
这时可用lsof命令获得使用它的进程信息，然后在应用中停止使用该设备或停止该进程。

### 文本转换
#### 文件编码
`vim :set fileencoding=encoding`
`iconv -l`列显系统所支持的字符编码
`iconv -f <from_encoding> -t <to_encoding> <input_file>`
`iconv -f ISO8859-1 -t UTF-8 -o file.input > file_utf8`//-o输出

#### 换行转换
DOS文件格式中使用CR/LF换行，在Unix下仅使用LF换行，sed替换命令
`DOS转UNIX：$ sed ‘s/.$//’dosfile.txt > unixfile.txt`
`UNIX转DOS：$ sed ‘s/$/\r/’unixfile.txt > dosfile.txt`

### 文件名编码转换
`convmv -f encoding -t encoding [option] filename`
* [option]
  * --notest 对文件进行真实操作，默认是不对文件操作的
  * -r 递归
  * --list 显示支持的所有编码sudo apt-get install wine playonlinux
  * --unescap 转义将%20之类的转义

  ### ssh

  * 生成公钥
    * ssh-keygen -t rsa
    * ssh-keygen -t rsa -C "vcl0000@163.com"
  * 公钥上传到服务器
    * ssh-copy-id -i ~/.ssh/id_rsa.pub username@host
  * ssh 登录
    * ssh username@host

  ### telnet
  `telnet host port`  测试端口是否开启

  ### 端口
  - **开启**
  `sudo iptables -I INPUT -p tcp --dport 21 -j ACCEPT`
  `iptables-save` 保存修改
  - 查看改端口被什么程序占用
    - `lsof -i:port`
    - `sudo netstat -lnp | grep 8080`

  ### ftp
  **vsftpd**
  `sudo vi /etc/vsftpd/vsftpd.conf`   ftp 配置文件
  `systemctl enable vsftpd.service` 开机启动
  `/etc/vsftpd.conf` configFile

### 下载
#### **wget**

commond|选项
---|---
-c|断点续传
-t|重试的次数
-r|递归下载即下载站
-l|递归的层级
-i|从文件下载 一个连接为一行的文件
-m|下载指定类型的文件
-A,–accept=type|可以接受的类型
-R,–reject=type|拒绝接受的类型
**密码认证**

 - –http-user=USER设置HTTP用户
 - –http-passwd=PASS设置HTTP密码
#### **curl**

选项|含义
---|---
-C|在保存文件时进行续传
-O|按服务器上的名称保存下载的文件
-u|用用户名和密码登陆。如curl -uname:passwd URL
-o|ut  将指定curl返回保存为out文件，内容从html/jpg到各种MIME类型文件。如 curl-opage.html URL
-d|key=value>  向服务器POST表单数据 例如：curl -d "order=111&count=2" http://www.jbxue.com/buy

### 加密
#### openssl
`tar -zcf - DIR | openssl enc -e -aes256 -salt -out DIR.tar.gz`
`openssl enc -d -aes256 -salt -in DIR.tar.gz| tar -xz -C DIR`
#### gpg
选项|含义
---|---
-c|使用密码加密
-e|加密数据
-d|解密数据
-r|为某个收件者加密('全名' 或者 'email@domain')
-a|输出经过 ascii 封装的密钥
-o|指定输出文件
- **example**
 - `gpg -c file`使用密码加密文件 生成file.gpg
 - `gpg file.gpg`文件解密 -o其它文件`gpg -o target.file file.gpg`
 - `gpg --gen-key`生成秘钥对
 - `~/.gnupg/pubring.gpg` 包含公钥和所有其他导入的信息
 - `~/.gnupg/secring.gpg` 可包含多个私钥
 - `gpg -e -r 'Your Name' file`使用你的公钥加密,需要使用全名来确定秘钥
 - `gpg -o file -d file.gpg`解密

- **密钥管理**
KEYID 跟在 '/' 后面 比如:pub 1024D/D12B77CE 它的 KEYID 是 D12B77CE
 - `gpg --list-keys`列出所有公钥并查看其 KEYID
 - `gpg --gen-revoke'Your Name'`产生一份撤销密钥证书
 - `gpg --list-secret-keys`列出所有私钥
 - `gpg --delete-keys NAME`从本的密钥环中删除一个公钥
 - `gpg --delete-secret-key NAME`从本的密钥环中删除一个私钥
 - `gpg --fingerprint KEYID`显示 KIYID 这个密钥的指纹
 - `gpg --edit-key KEYID`编辑密钥(比如签名或者添加/删除 email)

### screen
Screen 提供了两个主要功能:

- 在一个终端内运行多个终端会话(terminal session)。
- 一个已启动的程序与运行它的真实终端分离的,因此可运行于后台。真实的终端可以被关闭,还可以在
稍后再重新接上(reattached)。
在 screen 会话中,我们可以开启一个长时间运行的程序(如 top)。Detach 这个终端,之后可以从其他机器reattach 这个相同的终端(比如通过 ssh)。
- 当程序内部运行终端关闭并且你登出该终端时,该 screen 会话就会被终止。
commond
`screen`开启Screen
`Ctrl-a Ctrl-d`detach终端
`screen -r`Reattach终端
`screen -R -D`Reattach终端,若没有可恢复的开启新的

选项|含义
---|---
Ctrl-a ?|各功能的帮助摘要
Ctrl-a c|创建一个新的 window (终端)
Ctrl-a Ctrl-n 和 Ctrl-a Ctrl-p|切换到下一个或前一个 window
Ctrl-a Ctrl-N |N 为 0 到 9 的数字,用来切换到相对应的 window
Ctrl-a "|获取所有正在运行的 window 的可导航的列表
Ctrl-a a|清楚错误的 Ctrl-a
Ctrl-a Ctrl-d|断开所有会话,会话中所有任务运行于后台
Ctrl-a x|用密码锁柱 screen 终端







### ing
**fuser	lsof	patch**


## 引导
### 启动脚本
- init 运行级别 0-6
 - 0完全关闭系统
 - 1或S单用户模式
 - 2~5包含联网支持
 - 6重新引导(`reboot`)
- 0,6系统实际上不能停留在这两个运行级别上；多数情况下正常的多用户运行级别时2,3;Linux 5常用于 X Windows登录；4很少使用用
`telinit [n]` 迫使 init 进入该运行级别，-q参数重读/etc/inittab文件
- 启动脚本存放在`/etc/init.d` 下，在`/etc/rc[n].d`等目录下建立这些脚本的链接。
- 链接都是以S/K开头数据脚本控制的服务名。
- init从低运行级别向高运行级别过度时按照数字的递增顺序，带start参数运行S开头的脚本；init从高运行几别向低运行级别过度时按照数字顺序递减，带stop参数运行K开头的脚本。
- 启动脚本按照数字顺序执行,由此可以配置依赖。
- `/etc/inittab`文件告诉init在每个运行级别上需要运行或保持运行的命令。
- 启动脚本在不同的发行版之间差距非常大。
 - Red Hat 在每个运行级别上，init都把新运行级别作为参数来调用脚本`/etc/rd.d/rc`。`chkconfig`启动脚本在`/var/lock/subsys` 目录保存锁文件。`/etc/rc.local`脚本作为启动过程的一部分，时最后一个运行的脚本。
 - SUSE 在每个运行级别上，init都把新运行级别作为参数来调用脚本`/etc/init.d/rc`。 配置文件在`/etc/sysconfig`。 `/etc/init.d/README`SUSE引导过程的介绍
 - Ubuntu 使用Upstart代替init，事件驱动，模仿传统的运行级别。使用`/etc/init.d`目录里的作为定义文件代替inittab文件。
 	- `update-rc.d`命令维护rc目录下给启动脚本的链接
 	- update-rc.d service { start | stop } sequence runlevels .
 - AIX 执行用ksh编写的脚本`/sbin/rc.boot`,对`/etc/inittab`的依赖较高。

#### **update-rc.d**
- sudo update-rc.d commondd defaults//设置默认的运行级别，默认启动为2,3,4 和 5,停止为 0,1 和 6
- sudo update-rc.d　commondd start 20 2 3 4 5 . stop 20 0 1 6 .//20为启动和关闭的顺序即第而是个启动
- sudo update-rc.d -f commondd remove //在左右运行级别下禁用

### shutdown
- -r 重新引导（reboot）//调用reboot
- -h 停机（halt）//调用halt

## 访问控制 超级权限

访问权限的设计有很多中，比如设置命令以什么身份执行`setuid`，基于角色的访问控制(sudoers的分组可以模拟到这一点)等

- **口令**:出人意料的废话，既没有意义又出人意料，恶俗不可描述的，别人不会知道也就没有恶意 -_-!
- su
 - 不带参数的su不记录以root身份执行了哪些命令，但会记录谁在什么时间变成了root
 - `su - username`以登录shell派生shell
- sudo
 - 允许以root或其他身份运行命令
 - `/etc/sudoers`文件列出了授权谁在哪台主机上运行什么命令，该文件使用visudo编辑，严格语法检查。sudo会保有一个日志，记录xxx信息。
 - `sudo -u db2inste db2start`
 - but sudoers对于不能运行某些命令的限制是可以破解的 比如`cp -p /bin/bash /tmp/bash``sudo /tmp/bash`

###口令代管
一个正常情况下不能获得的口令，可以在进击情况下被使用。系统会通知系统管理员名单里其他人，并记录这个口令的行为。
### root之外的伪用户
- uid为10~100的用户，这些用户一般是不可以登录的 shell为/bin/false或/bin/nologin
- NFS使用nobody账号代表其他系统上的root，为了去除远端机器上的root权限，把远端UID为0的用户映射到别的账户上，nobody充当了远端root的替身

## 进程
进程的UID和EUID一般是一致的，除非使用setuid改变进程的运行时权限
### 后台
nohup 后台运行默认输出到当前目录的nohup.out

* 后台运行的子shell不会受终端I/O的限制。
* `nohup command > nohup.log 2>&1 &`
* jobs -l 显示后台进程，并显示进程号
* ^Z:挂起;bg:后台;fg:切换到前台;
* `pgrep -a commond` 查找进程 -a list-full

### 谦让值
高谦让值表示进程具有低优先级
进程的谦让值可以在创建进程时用 nice 命令来设置,并可以在执行时使用 renice 命令进行调整。nice 带一个命令行作为参数,而 renice 带 PID 或者(有时候)带用户名作为参数。

- `nice -n 5 ~/bin/longtask` // 把优先级降低(提高谦让度)5
- `sudo renice -5 8829` // 把谦让值设为-5
- `sudo renice 5 -u boggs` // 把 boggs 的进程的谦让值设为 5

shell 会自带nice 因此非完整路径的nice使用的是shell的
shell的 nice 要求它的优先级增量用+incr 或者-incr 来表达,而独立的 nice 命令则要求用-n 标志,后跟优先级增量
独立的 nice 命令把 nice -5 解释成值为正 5 的增量,而 shell 的内置 nice命令会把同一形式解释成值为负 5 的增量。
prio 是一个绝对的谦让值,而 incr 是一个相对的优先级增量,要把它加上 shell 的当前优先级,或者从 shell 的当前优先级中减去。无论用-incr 还是-prio,都可以用两个短划线输入负值(例如,--10)。只有 shell 的 nice 才能理解加号(实际上,它需要加号)


### ps

选项|含义
---|---
-a|显示所有的进程
 a|显示所有的进程,包括其他用户的程序
-x|显示没有控制终端的进程
-u|“面向用户”的输出格式
-l|“长格式”输出
-e|所有的进程//和a一样
 e|列出程序时，显示每个程序所使用的环境变量
-f|设置输出格式

### top
选项|含义
---|---
`- L`|搜索
`- &`|下一个
`- <>`|上下翻页

htop 键入 f 选择显示的column

### proc
/proc 目录下的进程信息文件(数字编号的子目录)

文件|内容
---|---
cmd|进程正在执行的命令或者程序
cmdline\[a]|进程的完整命令行(以 null 分隔)
cwd|链到进程当前目录的符号链接
environ|进程的环境变量(以 null 分隔)
exe|链到正被执行的文件的符号链接
fd|子目录,其中包含链到每个打开文件的描述符的链接
maps|内存映射信息(共享段、库等)
root|链到进程的根目录(由 chroot 设置)的符号链接
stat|进程的总体状态信息(ps 最擅长解析这些信息)
statm|内存使用情况的信息
\[a]: 如果进程被交换出内存的话可能得不到

### strace
直接观察一个进程,进程每调用一次系统调用,以及每接收到一个信号,这个命令都能显示出来
AIX:truss
`sudo strace -p PID`

## 周期性进程
### cron
- cron读取一个或多个配置文件，这些配置文件中包含了commond及调用时间的清单。commond是由sh执行，也可以配置cron使用其他shell。
- 每个用户的crontab都保存在 /var/spool/cron 目录下，每个用户最多有一个crontab文件，crontab文件是以它们的所属用户名来命名的。直接编辑crontab文件可能会导致cron没有注意到。
- cron的默认日志文件一般为`/var/cron/log`或者`/var/adm/cron/log`
### crontab文件格式
minute hour day month weekday command

字段|描述|范围
-|-
minute|小时中的分钟|0~59
hour|天中的小时|0~23
day|月中的天|1~31
month|年中的月|1~12
weekday|星期中的天|0~6(0=星期天)
- *匹配所有字符，x-x指定范围，时间范围/步长值(1-10/2),同时指定day和weekday的话同时满足才会执行(都是天具有一些二义性)
- command不需要加引号。也不是以登录shell执行的，不会读取~/.profile文件质之类的。可以把命令放到脚本中。使用%表示command的换行

### crontab管理
- `crontab file`把file安装为crontab文件，替代任何以前版本的crontab文件。
- `crontab -e`检出crontab的一个副本调用编辑器（环境变量EDITOR所指定），然后将其重新提交给crontab目录
- `crontab -l`将crontab中的内容输出
- `crontab -r`将会删除，不留下crontab文件的一点内容
- `crontab -u [userName]`,root可以指定用户名来操作某个用户的。
- `crontab`从标准输入中读取crontab内容。^D会保存，^C就只是终止掉了，可以提供`-`作为文件名参数 让crontab从标准输入读取它的内容。
- `/etc/cron.deny`,`/etc/cron.alllow`,指定了哪些用户可以提交crontab文件。`cron.alllow`一行一个用户没有被列出的用户不能调用crontab；没有上一个文件检查这个`cron.deny`被列出的用户不允许调用crontab
- cron 除了检查每个用户的crontab外，还遵守系统的crontab，系统的在`/etc/crontab`文件中,`/etc/cron.d`目录下。配置格式稍有不同，在command之前多出一个userName字段，其中的命令能以任何用户身份执行。`/etc/cron.d`目录下的一般是软件包安装的crontab文件，习惯上用安装它的软件名命令，但也无所谓。
- Linux发行版还会预先安装若干crontab配置项，例如`/etc/cron.daily`中的脚本每天运行，`/etc/cron.weekly`中的脚本没周运行一次。。。



## 文件权限控制
### 挂载/卸载文件系统
- `mount [directory | device ]` mount不指定类型会自动选择类型
挂载在某个特定系统上的文件系统清单保存在/etc/fstab文件中，当系统引导时，这个文件中的信息先被fsck再被自动mount
- umount卸载文件系统，大多数文件系统上上不能卸载处于繁忙(busy)状态的文件系统，在该文件系统中不能又任何打开的文件，也不能又任何进程的当前目录，文件系统若包含可执行程序那这些程序也不能处于运行状态。
- linux定义了一种lazy的卸载方式`umount -l`调用所有访问停止才能真正卸载，but不能保证当前访问都会自动关闭，其次半卸载会给使用文件系统的程序带来不一致（可以通过已有的文件句柄执行读写，却不能打开新的文件或者执行其他文件系统操作）
- `umount -f` 强制卸载一个处于繁忙状态的文件系统
- `fuser -c [mountpoint]` 查找该该挂载点文件系统上某文件或目录的每个进程的PID，再加一串字母显示反应状态, -v显示进程相关信息。`lsof`比fuse更先进更复杂
- 挂载iso `sudo mount -t iso9660 -o loop ~/download/linuxmint-18.2-cinnamon-64bit.iso /media/Mint`
**fuser反应码**

代码|含义
---|---
f,o|进程有一个为了读或些而打开的文件
c|进程的当前目录子在这个问价系统上
e,t|进程目前在执行一个文件
r|进程的跟目录(chroot命令设置)在这个文件系统上
m,s|进程已经映射了一个文件或者共享库

### 文件类型
ls使用的文件类型代码(ls -ld查看文件夹信息)

文件类型|符号|创建方式|删除方式
-|-
普通文件|-|编辑器，cp等|rm
目录|d|mkdir|rmdir,rm -r
字符设备文件|c|mknod|rm
块设备文件|b|mknod|rm
本地域套接口|s|socket|rm
有名管道|p|mknod|rm
符号链接|l|ln -s|rm
rm -i删除前询问，rm -i xx* 删除复杂文件名文件的技巧

- rm --参数告诉后边的参数是文件名不是选项 对名为-f的文件`rm -- -f`
- **目录** 目录的执行权限代表是否能进入，读取执行代表能否列出，写入执行代表能否在目录中创建删除A和重命名文件。

###文件权限
`-rwxr-xr-x 1 root root 211224 4月  29  2016 /bin/grep`

- 第一列是类型
- 第二列是权限，如果设置了setuid位属主的执行权限是s，设置了setgid位组执行权限的x也会被s替代，粘附位被打开的话其他人的执行位为t。如果设置了setuid，setuid，粘附位，但没有相应的执行权限那么这些位就显示为S或T。脚本的可执行需要读取和执行权限，让解释器读取该文件。二进制文件是由内核直接执行因此不需要读取权限。
- 第三列表示该文件的链接数目(硬链接)，所有目录至少拥有两个硬链接：来自父目录的链接和来自目录内部`.`的链接。
- 之后是文件的所有，文件系统保存的是uid，若用户从/etc/passwd中删除则显示uid
- 文件大小，设备文件显示主设备号和次设备号 `ls -l /dev/tty0`
`crw--w---- 1 root tty 4, 0 6月  26 21:25 /dev/tty0`
`/dev/tty0`第一个虚拟控制台，设备驱动程序是4（终端驱动程序）
- 文件内容的修改时间和文件属性的修改时间是不一样的。

#### chmod
-R 递归更新目录下所有

规则|含义
-|-
u+x|所有者添加写入
ug=rw,o=r|所有者组添加读写，其他人读
a-x|所有减去执行
ug=srx,o=|设置setuid setgid位，其他置空
g=u|所有者的权限给属主

#### chown chgrp
`sudo chown user:group dir`chown可以同时改变组和所有者

#### umask
分配默认的权限
umask默认值是022,因此默认创建文件的默认权限是777-022=755
可在/etc/profile $HOME/.profile 修改默认umask值

## 存储
- `suod fdisk -l`列出系统中的硬盘
- 2TB一下的硬盘可以使用windows MBR分区表，可以使用`fdisk`，`sfdisk`，`parted`。再大的硬盘就要用GPT分区表，必须使用`parted`分区。
- 使用LVM处理分区,假设新分区的设备名为`/dev/sdc1`
 - `sudo pvcreate /dev/sdc1`准备提供LVM使用
 - `sudo vgcreate [vgname] /dev/sdc1`创建卷组
 - `sudo lvcreate -l 100%FREE -n volnamevgname`创建逻辑卷
 - `sudo mkfs -t ext4 /dev/vgname/volname`创建文件系统
 - `sudo mkdir mountPoint`创建挂载点
 - `sudo vi /etc/fstab`设置挂在的选项和挂载点
 硬盘挂载在`/dev/vgname/volname`，可以使用UUID=xxx代替设备文件。查看设备UUID`blkid`/`ls -l /dev/disk/by-uid`
 - `sudo mount mountPoint` 挂载这个文件系统

- 磁盘设备文件
linux 磁盘块设备文件名 /dev/sda
`parted -l` 可以列出系统上每个磁盘的大小，分区表，型号等信息

- `mkfs`  `mkfs -t ext4 -c /dev/sdax`在/dev/sdax上创建一个ext4文件系统，同时检查是否有坏轨存在。-c检查坏轨

- SATA 完全擦除，防止文件恢复，可以使用`hdparm`命令。

- `hdparm [opentios] device`hdparm命令提供了一个命令行的接口用于读取和设置IDE或SCSI硬盘。

参数|作用
-|-
-I|转储许多标识和状态信息
-M value|设置噪声管理参数
-S value|设置自动待机（停转）模式的延迟时间
-y|让磁盘立即进入待机模式
-C|查询硬盘当前电源管理的状态
-T|快速检测接口贷款（不实际执行读硬盘的操作）
-t|快速整个盘片到主机的顺序操作
### 分区
- 分区和逻辑卷管理是把一个硬盘（在LVM下，一个硬盘池）划分成已大小独立的块，可以把单个分区置于逻辑卷管理程序的控制之前，但不能对一个逻辑卷分区。
- 时把交换分区，繁忙的文件系统放到多个不同的硬盘，可以提高性能。
- 在硬盘的起始位置写一个“标签”固定这个分区的数据范围，这个标签经常会和其他启动信息共存。Windows这个标签叫MBR主引导记录(master boot record)
 - MBR可以定义四个分区，因为是直接定义在MBR里的因此被成为主分区。也可以把主分区定义为一个扩展分区，它包含自己的次级分区表。次级分区表保存在分区数据的开头
  - windwos分区硬盘的一些规则
   - 一个硬盘上只有一个扩展分区
   - 扩展分区应该是MBR里定义的最后一个分区；它后面没有主分区。
   - 有些比较老的系统被装到次级分区会有麻烦。
   - windows的分区系统可以把一个分区标为活动分区，引导加载程序要找到这个活动分区，尝试从这个分区里加载操作系统
- GPT
 - EFI旨在取代BIOS的不稳固规范，EFI的分区分区方案得到了各个操作系统的广泛支持。
 - EFI分区使用一种GUID分区表，GPT只定义了一种类型的分区，可以任意创建多这个这样的分区。GPT通过带一个MBR作为分区表的第一块保持了和基于MBR系统的原始兼容性，这个“假”MBR让硬盘看上去被一个大MBR分区占据。各种磁盘管理工具对GPT的支持参差不齐，因此在非2TB以上的硬盘没有什么非用不可的理由。
- 分区工具`fdisk`,`parted`,GUI的`gparted`,`cfdisk`
- ZFS 自动给硬盘做标签并应用GPT分区表，but还可以使用format手工分区。

### RAID 廉价磁盘冗余阵列
- RAID有软硬两种实现，有比没有好软的也是RAID
- RAID把数据“条带式”地分散到多个硬盘上，因为能让多个磁盘读操作一条数据流，所以提高性能；RAID在多个硬盘上“复制”数据，降低磁盘故障带来的风险。
 - 复制的两中方式。镜像数据块在硬盘上逐位复制，快消耗磁盘多；奇偶校验，慢消耗磁盘少。

- RAID级别，配置的不同方式。JBOD线性(只是一堆硬盘)，RAID 0 （数据分散到多个磁盘，提高效率），RAID 1（在多个硬盘上复制），RAID 0+1/RAID 1+0（01一起使用，同时活动性能和冗余性），RAID 5（数据和校验信息都分散到不同的硬盘，空间效率比镜像好），RAID 6（两个磁盘多校验能承受两块硬盘完全损坏不丢失数据）。逻辑卷管理器通常包含RAID 0 和RAID 1。
 - linux 可以使用专门 RAID（md），或者逻辑卷管理器。使用md任然可以使用LVM管理RAID卷上的空间。RAID 5，RAID 6 必须用md软RAID。
 - 故障恢复除了JBOD和RAID 0引发问题的设备被标记为有故障，除了性能下降，阵列任可以继续使用。RAID 5 和双硬盘的RAID 1只能容忍一块硬盘故障。更换过程只是替换硬盘就可以了，经过较长的一段时间会向空白硬盘重新写入校验或镜像信息。或者指定硬盘多热备份，发生故障时，故障硬盘自动与一块备份盘交换后立即开始重新同步。RAID 5 的若干问题被称作RAID 5 “写漏洞”。

- **mdadm**linux标准的软RAID实现叫做mdadm。md可以使用原始硬盘作为部件，但出于保持一致性的考虑给硬盘建分区表还是不错的。
 - 配置一个RAID 5 ，用三块500GB硬盘组成，使用gparted在每个硬盘上创建MBR表（msdos型分区表），所有硬盘空间分给‘unformatted’（未格式化）类型的分区。
 - `sudo mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sdb1 /dev/sdc1 /dev/sdd1`
 - 虚拟文件`/proc/mdstat`始终保存有md状态的汇总信息，以及所有磁盘的状态信息`watch cat /proc/mdstat`动态检测的惯用命令
 - mdadm从技术上不要求有配置文件，但提供的话也可以使用配置文件（一般是/etc/mdadm.conf），方便查找信息。`mdadm --detail --scan`可以到处配置，but不完整。`sudo sh -c 'echo DEVICE /dev/sdb1 /dev/sdc1 /dev/sdd1 > /etc/mdadm.conf'`,`sudo sh -c 'mdadm --detail --scan >> /etc/mdadm.conf'`。可以生成一个完整的例子。可以在启动或关闭的时候读取这个配置文件。在系统启动的同时也用新创建的配置文件启动阵列`sudo mdadm -As /dev/md0`。手工停止阵列`sudo mdadm -S /dev/md0`。mdadm 有一个 --monitor模式会启动一个守护进程持续运行，检测到有问题的时候可以通知用户。配置文件的MAILADDR行指定报警信息发给哪个接受者。
 - ubuntu会默认启动磁盘阵列，RedHat SUSE带有RAID的启动脚本样例。
  - Ubuntu `sudo update-rc.d mdadm enable`
  - SUSE `sudo chkconfig -s mdadmd on`
  - redHat `sudo chkconfig mdmonitor on`

### 逻辑卷管理
逻辑卷管理实质上是增强和抽象版的磁盘分区。多个设备组成卷组(volume group)，一个卷组内的数据块分配给逻辑劵(logical volume),逻辑卷用设备块文件表示，其功能就像磁盘分区
linux LVM2 相关命令

`sudo pvs`物理卷
`sudo vgs`卷组
`sudo lvs`逻辑卷
`lsblk`块设备
`blkid`设备UUID

对象|操作|含义
-|-
物理卷|pvcreate|创建
|pvdisplay|查看
|pvchange|修改
|vgcreate|核对
卷组|vgcreate|创建
|vgchange|修改
|vgxtend|扩展
|vgdisplay|查看
|vgck|核对
|vcgscan|启动
逻辑卷|lvcreate|创建
|lvchange|修改
|lvresize|改变大小
|lvdisplay|查看
物理劵可以是磁盘，磁盘分区，RAID阵列。
其实这些命令都是`lvm`的链接
LVM的命令以字母开头，字母表示命令在哪个抽象层面执行：pv操作物理劵，vg操作卷组，lv操作逻辑卷
- 创建步骤
 - 创建（定义）和初始化物理卷
 - 把物理劵加到一个卷组内
 - 在卷组上创建逻辑劵
- 例子
 - 使用之前的RAID阵列，条带和冗余性直接使用RAID的，虽然LVM2也有这些功能。
 - `sudo pvcreate /dev/md0`创建物理卷组`sudo pvcreate /dev/sda2`
 - `sudo vgcreate [DEMO] /dev/md0`创建卷组`sudo vgcreate vg1 /dev/sda2`
 - `sudo vgdisplay DEMO` 查看
 - `sudo lvcreate -L 100G -n [web1] DEMO`在DEMO卷组上创建web1逻辑劵,可以通过`/dev/DEMO/web1`访问逻辑劵。LVM2可以在卷组上建条带，镜像。`sudo lvcreate  -L 30G -n lv1 vg1`
 - `sudo mkfs /dev/DEMO/web1`,`sudo mkdir /mnt/web1`,`sudo mount /dev/DEMO/web1 /mnt/web1`格式化，挂载。
- 逻辑卷快照 给`/dev/DEMO/web1`创建一个`/dev/DEMO/web1`
 - `sudo lvcreate -L 100G -s -n web1-snap DEMO/web1`,快照的源逻辑卷必须按“卷组/劵”的方式指定，理论上应该是先卸载文件系统一致性，实际上可能会丢失最近的备份数据块但ext4能保护文件系统不会受损。`lvdisplay`可以查看快照的状态，如果输出某个快照没有在活动的状态，意味着它已经用完了空间，应该被删除。
- 给逻辑卷扩容
 - `sudo umount /mnt/web1`
 - `sudo lvchange -an DEMO/web1`
 - `sudo lvresize -L +10G DEMO/web1`
 - `sudo lvchange -ay DEMO/web1`
 - `sudo e2fsck -f /dev/DEMO/web1`,`resize2fs`需要在改变文件系统大小之前检查文件系统的一致性。
 - `sudo resize2fs /dev/DEMO/web1`改变文件系统的大小,`resize2fs`支持ext类文件系统，能够判断文件系统在逻辑劵里的大小，因此不需要明确指定文件系统新的大小。只有在缩小的时候才需要指定。
 - `sudo mount /dev/DEMO/web1 /mnt/web1`挂载。
#### 删除
卸载卷组上的逻辑卷LV
`sudo lvremove  /dev/vg1/vg1-lv1` 删除逻辑卷LV
`sudo lvremove  /dev/vg1/vg1-lv2`
`sudo vgremove  vg1`删除卷组VG
`sudo pvremove  /dev/sda2`删除物理卷PV

### 裸设备
`sudo modprobe raw`
`sudo raw /dev/raw/raw1 /dev/vg1/lv1`

### 文件系统
- ext4
 - `tune2fs -j /dev/xx`把ext2转换为ext4
- `fsck` 文件系统一致性检查
 - `sudo /sbin/tune2fs -c 50 /dev/xx`把执行文件系统检查的时间增加到50次挂载，默认是20次
- 交换分区
 - `mkswap [device]`初始化交换分区
 - `swapon [device]`启用交换分区
 - `swapon -s` 查看交换分区
 - 交换分区也可以是一个文件


## 备份
给备份截止家劵标，文件系统的列表，备份日期备份格式，创建备份的确切命令语法等详细信息。
很少修改的文件系统不必要频繁备份，某个静态文件系统中只有少数文件有变化，应该把这些文件复制到另一个定期做备份的分区中。
### dump restore
`dump`
- 备份可以跨越多卷磁带；
- 任何类型的文件，设置是设备都能被备份和恢复
- 范文权限，归属关系，修改时间都被保留下来
- 有“空洞”的文件能够得到正确的处理
- 备份能都以增量的方式进行（只把修改过的文件些到磁带上去）
- dump不关心文件名的长度，目录层次可以任意深
- but 每个文件系统必须单独转储备份，只能转储本地计算机中的文件系统，NFS之类的不可以
dump的增量要比tar的较为高级些

- -u 在转储完成之后自动更新`/etc/dumpdates`文件，将日期转储几倍和文件系统的名称都记录下来。未使用-u那么所所有的转储级别都会变为0，将不会有先前备份过当前文件系统的记录。
- -f 制定输出的位置，不适用-f 默认是主磁带机
默认SCSI磁带涉笔的涉笔文件 倒带`/dev/st0`,非倒带`/dev/nst0`
- 转储数据到一个远程系统时，必须把远程磁带驱动器制定为hosname：device的形式。`sudo dump -0u -f anchor:/dev/nst0 /spare`

`restore`从转储中恢复
- -r完全恢复整个文件系统
- -i 从此带中读取备份目录，然后可以使用ls cd 这样的命令遍历转储目录，使用add 命令标价那些需要恢复的文件。选好后键入extract命令将文件从磁带中提取出来

### tar
tar的默认输出是磁带
tar能保存文件的所有权信息和时间信息
GUN的tar在创建是一个存档时-S选项能够聪明地处理空洞。

### dd
dd命令使用不正确的话会有时候会破坏分区信息。
只能在两个大小完全相同的两个分区之间复制文件系统。
- if输出文件
- of输出文件
- bs以字节为单位的块的大小
- count 被复制的块数
- `dd if=/dev/xx of=/dev/xxx`备份到磁盘
- `dd if=/dev/xx of /path/file`备份到文件
- `dd if=/path/file of=/dev/xx`从文件恢复
- `dd if=/dev/xx | gzip > /path/file.gz`压缩备份到文件
- `gzip -dc /path/file.gz | dd of=/dev/xx`从压缩文件恢复
- `dd if=/dev/xx of=/path/file count=1 bs=512`备份MBR表,MBR表在磁盘的第一块，恢复`dd if=/path/file of=/dev/xx`

Bacula/Amanda 企业级备份软件

## 系统日志和日志文件

## 用户
### `/etc/passwd`

- `/etc/passwd`文件是系统能识别的用户的一份清单，but能够被目录服务扩展或替代，所以只有
- 在单机系统上才是完整权威的。
- 一个代表一个用户，共有七个字段用:分隔
登录名:加密的口令或占位符:UID:GID:GECOS信息:主目录:登录shell
- 加密口令实际被保存在`/etc/shadow`。散列+salt加密。MD5的口令以$md5$开头，SHA256以$5$开头
- 可以编辑该文件创建新账号(vipw),加密口令位不要为空否则不用口令就能访问这个账号
- 加密口令的算法在`/etc/login.defs`中设置
- 默认目录如果是网络文件系统，出现问题时会出现no home directory的提示，并打用户放到`/`下.`/etc/login.defs`中的DEFAULT_HOME设置为no会禁止没有主目录的用户登录

### `/etc/shadow`
- 同样一行一个用户，使用`:`分隔九个字段
 - 登录名,加密后的口令,两次修改口令之间最少的天数,两次修改口令之间最做多,提前多少天警告用户口令即将过期,在口令过期之后多少天禁用账号,账号过期的日期,保留字段目前为空。
- 指定的绝对日期是从1970年1月1之间的天数，可以通过以下命令计算```expr `date +%s` / 89400```
- 可以使用`pwconv`工具让shadow文件的内容和passwd文件的内容保持一致，pwconv会用/etc/login.defs文件指定默认值填写打多少shadow参数。
### `/etc/group`
多个用户之间使用`,`分隔不可有空格

### 添加用户
- useradd `useradd`配置文件位置`/etc/login.defs`/etc/defult/useradd`。
 - `sudo useradd -d /home/newUser -g newGroup -G otherGroup -m -s/bin/sh newUser`
 -m参数指定主目录不存在创建，并复制启动文件
 -g 用户的初始组
 -G 还属于哪些组`,`分隔无空格
 -U 创建一个和用户名一样的组并添加用户到组
 `sudo useradd -d /home/username -U -m -s /bin/bash username` 没有制定的信息会根据配置文件的相关配置设置
 - ubuntu 还提供了adduser命令，配置文件位置`/etc/adduserconf` 是更友好的perl版本，提供了建主目录，复制启动文件等。

启动文件的样本一般都保存在`/etc/skel`下
改变HOME 目录的所有权时应该 `sudo chown -R newUser:newGroup dir`，不能使用 ./* 这样会改变..的所有权。
### 删除用户
#### 完全删除用户
- 从aliases文件中删除或者添加一个转发地址
- 删除用户的crontab文件和所有挂起的at作业或打印作业
- 种植所有仍在运行的用户进程
- 将用户从passwd shadow group gshadow文件中删除
- 删除用户的主目录
- 删除用户的邮件存储文件
- 清理共享的日历，空间预留系统等上面的数据项
- 删除被删除用户运行的任何邮递列表，或者改变其所有权。
- `sudo find fileSystem -xdev -nouser` 只在本地的文件系统查找 不属于本地用户的文件
nouser 找出不属于本地主机用户识别码的文件或目录
xdev 将范围局限在当前的文件系统中

`uerdel`命令自动完删除一个用户的进程but可能不会完全删除
同样ubuntu提供了`deluser`会撤销`adduser`做的所有事情



#### 命令实例
- **添加用户**
`adduser username` ubuntu的perl脚本
`passwd username`
`groupadd groupname`
`sudo groupdel was` 删除组
- **新建用户同时增加工作组**
`useradd -g groupname username`
- **用户追加到组 没有a用户将从原来的组中移除**
`usermod -a -G group user`
- **将用户将从组中删除**
`gpasswd -d user group`
- **查看当前用户所在的组**
`groups`
- **查看组下有哪些用户**
`groups groupname`
- **将用户从组中删除**
`gpasswd -d username groupname`
- **完全删除用户**
`userdel -r [username]`



## 软件安装和管理
like UNIX都可以通过网络引导安装
软件包二进制文件可以放到NFS中
wrapper封装程序，能够解决依赖等

### apt
-yes选项，对任何确认性问题回答yes
--download-only下载所有改动过的软件包，但是不安装，下载的软件包都保存在`/var/cache/apt`里

#### apt-get 依赖问题
- 强制安装依赖 apt-get -f install
- 备份/var/lib/dpkg/info
- rm /var/lib/dpkg/info
- mkdir /var/lib/dpkg/info
- apt-get install package
#### apt-get 清理包

- apt-get purge / apt-get –purge remove
删除已安装包（不保留配置文件)。
如软件包a，依赖软件包b，则执行该命令会删除a，而且不保留配置文件
- apt-get autoremove
删除为了满足依赖而安装的，但现在不再需要的软件包（包括已安装包），保留配置文件。
- apt-get remove
删除已安装的软件包（保留配置文件），不会删除依赖软件包，且保留配置文件。
- apt-get autoclean
APT的底层包是dpkg, 而dpkg 安装Package时, 会将 *.deb 放在 /var/cache/apt/archives/中，apt-get autoclean 只会删除 /var/cache/apt/archives/ 已经过期的deb。
- apt-get clean
使用 apt-get clean 会将 /var/cache/apt/archives/ 的 所有 deb 删掉，可以理解为 rm /var/cache/apt/archives/*.deb。

- 删除软件及其配置文件
`apt-get --purge remove <package>`
- 删除没用的依赖包
`apt-get autoremove <package>`
- 此时dpkg的列表中有“rc”状态的软件包，可以执行如下命令做最后清理：
`dpkg -l |grep ^rc|awk '{print $2}' |sudo xargs dpkg -P`

### apt-mirror
apt源镜像
`/etc/apt/mirror.list`是source.list的屏蔽版本


### 添加源
 - 源设置 `/etc/apt/sources.list`文件,`/etc/apt/sources.list.d`目录
 - `sudo apt-cdrom -m -d /media/Mint/ add` 添加镜像

### 更新
- `sudo apt-get update`更新缓存
- `sudo apt-get upgrade`
- `sudo apt-get dist-upgrade`安装本地机器上安装过的任何软件包的新版本，处理依赖关系要比update聪明些。可能会删除它任务和跟新过的系统不兼容切解决不了的一些软件包，可能会有预期之外的后果。


### dpkg
选项|含义
---|---
-i|安装
-r|卸载
-P|--purge
-l|list
-S file|查找拥有该文件的包
#### 打包
./内按照安装的目录结构组织
`DEBIAN/control`创建该文件。
`
Package: wkhtmltopdf
Version: 0.12.4
Section: utils
Priority: optional
Architecture: amd64
Depends: libc6 (>= 2.14), libgcc1 (>= 1:3.0), libqt5core5a (>= 5.6.0~beta), libqt5gui5 (>= 5.0.2) | libqt5gui5-gles (>= 5.0.2), libqt5network5 (>= 5.0.2), libqt5printsupport5 (>= 5.0.2), libqt5svg5 (>= 5.6.0~beta), libqt5webkit5 (>= 5.6.0~rc), libqt5widgets5 (>= 5.0.2), libstdc++6 (>= 5)
Installed-Size: 125300
Maintainer: vcl0000@163.com
Description: soft package
`
`dpkg -b . ../wkhtmltopdf-0.12.4.deb`

### rpm
```
-i 安装
-U 升级
-e 卸载
-q 查询,只用于其他选项，必须给出一个标志来提出特定的问题，例如-qa查询已安装的软件包的完整清单
--force 强制升级，但是会破坏依赖依赖关系
```

### alien
```
alien -d package.rpm
alien -r package.deb
```
### ldd
`ldd commondPath`列出所有所需的运行时库

## 驱动程序和内核
- 内核包含设备驱动程序，设备驱动程序管理着内核与特定硬件的交互，内核的其余部分很大程度上与和别无关。
- 内核可以把设备驱动程序和其他的内核功能按需添加，不需要重新构造内核，也不需要重启系统。驱动程序，文件系统同城都用模块实现。
- linux 内核的构造目录`/usr/src/linux`,内核`/vmlinuz`/`boot/vmlinuz`
- 驱动程序在设备可理解的硬件命令和内核使用的固定编程接口之间起转换作用。驱动程序的存在有助于内核合理的保持设备的独立性。
- 对设备的用户级访问往往要通过位于/dev目录下的特殊设备文件，内核把对这些设备文件的操作映射到对驱动陈旭代码的调用上。
### 设备文件
- /dev中的设备文件都有与之先关的一个主设备号，和一个次设备号，内核用这些设备好把对一个设备文件的引用映射到相应的驱动程序上。主设备号标明与文件相关的驱动程序（设备类型），次设备号常常是制定给某种给定设备类型的特别实例。
- `ls -l /dev/sda`;`brw-rw---- 1 root disk 8, 0 7月   6 20:59 /dev/sda`主设备号8，次设备号0，第一个SCSI磁盘。
- 设备文件有两种块设备和字符设备，块设备每日操作一块数据（一组字节，通常是512的倍数），字符设备每次操作一个字节。
- 设备驱动程序表示驱动程序到内核的一个标准接口。设备驱动程序没有控制实际的设备，这种不存在的虚拟设备被成为伪设备，`/dev/null`,`/dev/random`。

### 创建设备文件
- `mknod filename type major minor`filename要创建的设备文件；type c代表字符设备，b代表一个块设备；major 主设备号；minor次设备号。
- 为一个已经在内核中存在的驱动程序创建一个设备文件，需要查看驱动程序的手册页，找到合适的主设备号和次设备号。
- `udev`根据设备实际出现消失的情况动态的管理设备文件的创建好删除。射虎进程udevd监听内核传来的有关设备状态变化的消息。根据`/etc/udev`，`/lib/udev`中的配置信息在找到设备或断开设备的时候采取各种措施。默认情况下只在/dev里创建设备文件。
- 设备文件名规范。既有块设备文件也有字符设备文件的设备，字符设备名通常以字母r开头，代表“raw”（/dev/da0，/dev/rda0）。另一种约定是把字符设备文件放在名字以r开头的子目录。but，r不总是暗指一个raw（原始）设备文件。

### 配置Linux内核
配置内核的基本方法
- 修改可调（动态）的内核配置参数
- 从头build一个内核
- 随时把新的驱动程序和模块加入现有的内核
- 通过内核加载程序（GRUB）在引导时刻提供操作指令

#### 调整内核参数
通过文件系统的/proc中的文件表示内核到用户的接口。`/proc/sys`下的特殊文件能够让用户查看和设置内核正在运行时的选项。but不是所有文件都是可写的与文件权限无关。可以在内核源码中的 Documentation/syscnt 中了解一些取值的含义。

目录|文件|功能
-|-
C|autoeject|在卸载文件系统时自动弹出光盘
F|file-max|设置打开的最大文件数
F|inode-max|每个进程打开的最大索引节点数，程序要打开大量文件句柄，这个参数会有所帮助
K|ctrl-alt-del|使用组合键时重启系统
K|printk_ratelimit|内核消息最小间隔的秒数
K|printk_ratelimit_burst|在实际printk速率限制之前连续出现的消息数量
K|shmmax|设置对打共享内存的大小
N|conf/default/rp_filter|启用IP源路由验证机制
N|icmp_echo_ignore_all|设置1时忽略ICMP ping
N|icmp_echo_ignore_broadcasts|设置1时忽略广播ping;设置1几乎总是个好主意
N|ip_forward|设置1时允许IP转发，如果需要把主机单做路由器需要设置为1
N|ip_local_port_range|指定在建立链接期间分配的本地端口范围。
N|tcp_fin_timeout|指定等待最后FIN包1的秒数
N|tcp_syncookies|保护不受SYN洪泛攻击，如果换衣收到（DoS）攻击，可以打开它

`F=/proc/sys/fs`,`N=/proc/sys/net/ipv4`,`K=/proc/sys/kernel`,`C=/proc/sys/dev/cdrom`

`sysctl` 能从命令行或文件中杜宇 variable=value对来设置各变量。`/etc/sysctl.conf`文件默认实在系统引导时读取，它的内容游湖设置参数的初始值。`sudo sysctl net.ipv4.ip_forward=0`关闭IP转发功能，也可以修改`/etc/sysctl.conf`。用`.`代替目录中的`/`就成为sysctl里用的变量名
#### 构造Linux内核

- 大多数发行版把内核的源码放在`/usr/src`下，系统在构造内核之前都要安装内核源代码包。
- 配置内核的过程围绕着内核源代码根目录下的文件`.config`展开。内核的总有配置都在这个文件中指定的，`src/Documentation/Configure.help`里的指导可以了解各种不同的选项代表什么意思。
- 为了避免人们直接编辑.config文件linux有几种make的目标体，能用不同的变体来配置内核。 `make xconfig` 提供KDE界面，`make gconfig`提供GNAOME界面，可以从图形配置界面总选择要添加到内核的设备（或者编译为可加载模块）,`make menuconfig`使用一种基于curses的字符界面，`make config`提供一种较老的风格。
- 如果要把现有的内核配置到一个新版内核上（或者说内核源代码树里）`make oldconfig`读取以前的配置文件，并且只提出新出现的问题。
- .config文件中的每个CONFIG行都是指一个特定得到内核配置选项。值为y将这个选项编译到内核中，m启用和这个选项但作为一个可加载模块。

- 构建内核的二进制文件
 - 最重要的部分就是设定一个合适的.config文件
 - cd kernelPath
 - make gconfig 或make ..
 - make dep （2.6.x之后的不需要）
 - make clean
 - make
 - make modules_install;
 - 把 arch/i386/boot/bzImage 拷贝为 /boot/vmlinuz;
 - 把 arch/i386/boot/System.map 拷贝为/boot/System.map
 - 编辑`/boot/grub/grub.conf`(GRUB)为新内核加一行配置

#### 添加设备驱动程序

设备驱动程序一般会以下面三种形式之一发布
- 正对某个特定内核版本的补丁
- 可加载模块
- 施加适当修补的安装脚本或软件包

最常见的是针对某个特定内核版本的补丁。`cd kernel_src; patch -pl < patch_file`
是把新的设备驱动程序集成到内核源代码树里。

下例将假想的网络“snarf”驱动程序添加到内核中。
- 在内核源代码目录树的drives子目录中可以找到与自己用的设备类型对应的子目录。最常添加驱动的目录有`block,char,net,scsi,sound,usb`,这些目录分别包含了块设备（IDE磁盘驱动器），字符设备（串口），网络设备，SCSI卡，声卡，USB设备的驱动程序。有些目录包含了总线本身的驱动程序（pci,nubus,zorro）用户不太可能会向这些目录添加驱动程序。有些目录包含了针对平台的驱动程序（macintosh,s390,acorn）
- 举例的网络相关的设备，将驱动程序添加到dirvers/net目录中，然后修改下列文件
 - drivers/net/Makefile，这样驱动程序会被编译
 - drivers/net/Config.in，这样设备能出现在配置选项中。

- 在把这个驱动程序的.c和.h文件都放到drivers/net/snarf下后，在dirvers/net/Makefile里加上这个驱动程序。添加一行 `objec-$(CONFIG_SNARF_DEV) += snarf`。这样的配置把驱动程序snarf（放到snarf/目录下）加入到了构造内核过程中。
- 在把设备加到Makefile文件以后，必须保证在配置内核的时候配上和这个设备。所有的网络设备都必须列在文件drivers/net/Kconfig里。要加上这个设备，让它可以编译成为一个模块或者内核的一部分（与Makefile文件里的要求保持一致）就要加上这两行`config SNARF_DEV`,`tristate 'Snarf device support'`,cnfig 后的第一标记是配置宏，它必须和Makefile里CONFIG_后边的标记一致。关键字 tristate的含义是可以把这个涉笔编译成一个模块，如果设备不能编译成为一个模块，用bool代替tristate，下一个标记实在配置窗口上显示的字符串它可以是任意的文版，但应该说明正在配置的是什么设备。
- 内核的设备驱动程序都用宏MODULE_DEVLICE_TAVLE自行登记。这个宏建立正确的末后联系，像`modprobe`这样的其他工具就能启用内核中的新设备。


#### 可加载内核模块 LKM
- 让一个设备的驱动程序或其他内核服务被链接到内核内部，或者在驱动程序正在云信时，从内核中把它删除掉，不需要改变内核的二进制文件。
- 可加载模块放在`/lib/modules/[version]`目录中,version是指`uname -r`返回的内核版本号，可以使用`lsmod`来检查当前加载的模块
- `sudo insmod /patg/to/snarf.ko`加载snarf内核模块。`sudo insmod /path/to/snarf.ko io=0xXXX irq=X`给加载内核传递参数。
- 手工把一个内核加载模块插入到内核里之后，只有明确请求删除它，或当系统重启时，才能把它删掉。任何时候都可以使用`rmmod`命令，但是只有当前对这个模块的引用数为0，这个命令才能起作用，（lsmod输出里 Usered列给出的值）
- 还可以用`modprobe`半自动的加载linux的LKM，modprobe封装了insmod命令。modprobe使用`/etc/modprobe.conf`文件来推断出如何处理每个模块。`modprobe-c`可以动态的生成一个与当前已安装的内核模块相对应的`/etc/modpeobe.conf`文件，modprobe还可以理解`install`，`remove`语句，当从运行的内核中加载/卸载某个特定模块时，这些语句可以让这些命令得以执行。

**udev**
设备的越来越多，使得设备标识保持不变这一问题更加恶化了
`udev`依靠`sysfs`来了解系统的设备会发生什么情况，使用一系列udev特有的规则来理解合适的命名约定。udev把设备文件自动放到/dev目录下，而且对这个目录造成的破坏最小。只有系统当前能用的设备才在/dev下有文件。


- udev依靠一嘴规则来知道它对设备的管理以及给设备命令，默认的规则在位于`/lib/udev/rules.d`目录下，本地规则在`/etc/udev/rules.d`。主空配置文件`/dev/udev/udev.conf。

**sysfs**
`sysfs`,在内存里的虚拟文件系统，提供了系统上可用设备，设备的卑职及其状态的信息，这些信息组织清晰，内容详尽。
sysfs安装在`/sys`目录，/sys目录里的每个文件指标是下层设备的一个属性，这个乐町给原本混乱的数据集富裕了一定的结构性。

目录|说明
-|-
block|有关磁盘这样的块设备的信息
bus|内核知道的总线：PCI-E，SCSI，USB和其他总线
class|按设备的功能类型（声卡，显卡，网卡等）组织的树
dev|区分块设备和字符涉笔的设备信息
devices|正确表示所有找到的设备
firmware|特定于平台的子系统的接口如ACPI
fs|内核知道的一些但不是全部的文件系统的目录
kernel|内核的内部，如高速缓存和虚拟内存状态
module|内核动态加载的模块
power|系统电源状态的几种详细信息，大都不用
/proc有进程和内核正在运行时刻的信息，但是设备特有的所有信息则会逐步转移到/sys

**udeadm**浏览设备
- udevadm命令查询设备信息，触发时间，控制udevd守护进程还会见识udev和内核的事件。
- 第一个参数是下列枚举值info,trigger,settle,control,monitor,test
- info输出设备特有的信息，contril启动和停止udev或者命令udev重新加载它的规则文件，monitor在事件发生的同时就显示它们。
`udevadm info -a -n sdb`显示sdb这个设备所有udev属性。输出里的所有目录都是/sys的相对目录。

## 网络
TCP/IP五层模型“物理层 链路层 网络层 传输层 应用层”
数据以分组的形式在网络上传输，每个包由头和体构成，上层协议的体是下层协议的全部
一台网帧头|IP包头|UDP包头|应用程序数据|以太网
^			   udp包				 $
^		 IP包					 $
^以太网帧								$
最大传输单元（MTU）两种处理方式路由器分片，路由器返回ICMP出错消息发送段重新分片
### 分组地址
- 硬件(MAC)地址
- IP地址
 - DNS映射`/etc/hosts`

**IP地址分类**
IP地址根据最左边哪个字节的第一个比特位进行分类，分为5类。这种分类指定了哪些字节是网络部分，哪些字节是主机部分。路由系统用一个明确的掩码来指定网络部分，没给出明确划分的时候任然默认采用传统的分类。网络部分用N表示，主机部分用H表示

地址类型|第一个字节|格式|说明
-|-
A|1~126|N.H.H.H|美国国防部保留
B|128~191|N.N.H.H|大型网点，通常要划分子网
C|192~233|N.N.N.H|容易得到常常成组获得
D|224~239|-|组播地址，不是永久分配的
E|240~255|-|实验地址
0是特殊值，正规的IP地址是第一个字节不用0,127为环回地址保留

**子网**
通过指定一个明确的4字节“子网掩码”重新划分地址的主机部分和网络部分，对应一个IP地址网络部分的各个网络掩码位被设置为1，而主机位设置为0。比特位1必须从最左变开始而且连续。网络部分必须至少有8位而主机部分至少有2位。
B类地址4字节通常表示为N.N.H.H，点分十进制为255.255.0.0。子网掩码是255.255.255.0地址就是N.N.N.H。子网掩码可以把一个单独B类地址转换为256个不同的类似C类的网络。每个网络都能支持254台主机

CIDR无类域间路由

**私用地址和NAT**

保留部分地址不在Internet上出现。边界路由器能够在私用地址空间和ISP分配的地址空间之间进行转换。
一个A类，16个B类，256个C类，这些地址不在全网内分配，但可以在任意站点内部使用

IP分类|范围
-|-
A|10.0.0.0~10.255.255.255
B|172.168.0.0~1172.31.255.255.255
C|182.168.0.0~192.168.255.255
边界路由器上运行一个名为NAT（网络地址转换）的系统，NAt截取带有只带内部使用的地址包，然后用一个真是的外部Ip地址，获取还会有一个不同的端口号来改写这些包的源地址。NAT还维护着一张内外地址/源端口对之间的映射表，这样应答包到达的时候就可以进行反向转换了。

**路由表**
`netstat -r`-n避免做DNS查询，`ip route show`
Destination（目的地）字段通常就是一个网络地址，Gateway（网关）字段必须是一个为完整的IP地址，这个地址是本地网络接口的地址或者临接主机的地址。Linux 0.0.0.0表示默认网关。
为了到达目的地，必须通过Iface（网络设备）把包发往网关。主机可以将包只路由到直接链接到和他们同在一个网络上的网关计算机。
路由表
路由表可以静态配置也可以动态配置，只要系统还在运行静态路由就应该在路由表里。通常是通过一个系统启动脚本在系统引导时设置的。
`route add -net 132.236.220.64 netmask 255.255.255.193 gw 132.236.212.6 eth1`,`route adddefault ge 132.236.271.1 eth0`

**DHCP**
动态主机配置协议
一个设备或计算机要加入网络的时候，它通常要在网络上为它自己获取一个IP地址，设置一条正确的默认路由，还要让它自己能连上一台本地的DNS服务器。
DHCP客户机从中央服务器“借用”各种网络和管理参数。

## 网络文件系统
### NFS
- ubuntu 需要安装`nfs-common`,`nfs-kernel-server`
- 第三版中mountd服务用于挂在请求，nfsd服务用于实际的文件服务。下层系统依赖的协议是RPC（从而要求运行portmap）
- NFSv4不需要mountd，除非客户机和服务端都用NFSv4否则应该保持mountd运行。
- 在NFS服务器上`mountd` `nfsd` 应该在引导系统时运行。如果配置了任何exports目录那么系统启动脚本一般会自启动这些程序
- 各系统上的启动脚本
 - Ubuntu `/etc/init.d/nfs-kernel-server`,`/etc/init.d/nfs-common`
 - Red Hat `/etc/rd.d/init.d/nfs`
- NFS使用一个访问控制数据库来说明：应该导出哪些文件系统，哪些客户机可以挂载导出的文件系统。这个数据库供运行用的副本通常保存在`xtab`文件，另外还保存在内核的内部表里。可以使用`exportfs`来添加和修改该文件中的配置项。`exportfs -u`从导出表里删除配置项。
- `/etc/exports` 是导出目录的权威说明清单，`exportfs -a`命令可以读出这个文件的内容。exports文件修改过之后需要运行`exportfs -a`
- NFS是在逻辑层面上处理文件系统的。导出目录不必是一个挂在点或是一个物理文件系统的根。然而为了安全起见，NFS特别注意文件系统之间的接线，并要求每个设备单独导出。例如一台把/users设为单独一个分区的机器上，可以导出根目录的同时又不会导出/users。同时如果服务器导出了/path1/path2，客户机可以只挂载/path1/path2/path3，并且忽略path3目录下的内容。
- exports文件最左边一列是被导出的目录列表，后边是相关的选项`/home -vers=4,sec=sys,access=harp.atrust.com`,/home可以被harp.atrust.com挂载，挂载采用NFS协议第四版和UNIX身份验证。没有制定主机的话通常可以被所有的机器挂载
- `/etc/exports`导出选项

选项|说明
-|-
ro|以只读方式导出
rw|以读写方式导出（默认方式）
rw=list|大多数客户机为只读，list列出的主机允许以可些方式挂载NFS，其他所有主机必须以只读方式挂载
root_squash|将UID 0和GID 0映射成anonuid anongid所制定的值，只是默认方式
no_root_squash|允许root正常访问，这很危险
all_squash|将所有的UID和GID映射到它们各自的匿名版本上。用于支持PC和不可信的单主机
anonuid=xxx|指定远程root账号应被映射到的UID
anongid=xxx|指定远程root账号应被映射到的GID
secure|远程访问必须从授权端口发起
insecure|允许从任何端口远程访问
noaccess|防止访问这个目录及其子目录（用户嵌套导出）
wdelay|为合并多次更新而延迟写入磁盘
no_wdelay|尽可能块地把数据写入磁盘
async|让服务器在世界写磁盘之前就先回应写请求
nohide|暴露在导出的文件树中挂载的文件系统
hide|与nohide的作用相反
subtree_check|核实内个被请求的文件偶读位于导出的目录子树里
no_subtree_check|只核实涉及被导出的文件系统的文件请求
secure_locks|要求所有上锁的请求都要有授权
insecure_locks|指定较为宽松的上锁条件
sec=flavor|制定导出目录所采用的安全方法列表。flavor的值包括sys（UNIX身份验证）,dh(DES),krb5(Kerberos身份验证),krb5i（Kerberos身份盐城和完整性）,krb5p(KERberos验证 完整性和隐私性),none（匿名访问，不推荐）
fsid=num|指定NFSv4的为文件系统根（通常为0）

Linux的NFS服务器有个不寻常的特性，允许已被导出的目录的子目录以不同的选项再被导出。还提供noaccess选项，不导出不想共享的子目录
```
/home		*.atrust.com(rw)
/home/ben	(noaccess)
```
允许atrust.com域内的主机可以访问/home下除/home/ben之外的所有内容。

#### 客户端NFS
mount可以理解 hostName:directory
`showmount -e [hostName]`核实服务器导出的文件系统
`mount -t nfs [host]:[path] [mountPoint]`挂在NFS文件系统
NFS的挂载标志和选项

标志|说明
-|-
rw|以读写方式挂载文件系统（也必须以同样的方式来导出）
ro|以只读方式挂载文件系统
bg|如果挂载失败（服务器没有响应），后台一直尝试，继续发其他的挂载请求
hard|如果服务器宕机，让试图访问它的操作被阻塞，知道服务器恢复为止。
soft|如果服务器宕机，让试图访问它的操作失败，返回一条错误消息。这项功能对于被避免进程“挂”在无关紧要的挂载操作上说非常有用
intr|允许用户终端被阻塞的操作（并且让他们返回一条出错消息）
nointr|不允许用户中断
retrans=n|制定以软方式挂载的文件系统上，在返回一条出错消息之前重复发送请求的次数
timeo=n|设置请求曹氏时间（单位十分之一秒）
rsize=n|设置读缓冲的大小为n字节
wsize=n|设置写缓冲的大小为n字节
set=flavor|指定安全类型
vers=n|设置NFS协议的版本
proto=proto|选择一种传输协议；对于NFSv4来说必须是tcp

man手册页给出了vers标志，但是用这个标志则会出错。要使用NFSv4协议来瓜子啊文件系统的话要使用 `mount-tnfs4`命令

`nfsstat`显示NFS系统维护的各种统计信息。`nfsstat -s`显示NFS服务器进程的统计信息，`nfsstat -c`显示与客户端操作先关的信息，默认显示所有协议版本的统计信息

`sudo mount -t cifs -o username="vcl0000",password="*****" -l //192.168.3.1/honorrouter/ /home/vcl0000/n` 挂载smba
**自动挂载**
- 挂载守护进程在文件系统被访问到时就挂载文件系统，而不再需要文件系统时就卸载它们，这样可以来解决一些问题。自动挂载程序把活动挂载点的数目限定在一定范围内。大多数自动挂载程序还可以提供一些列“复制的”（等同的）文件系统。现在使用的是一种驻留内的的文件系统驱动程序autofs。
- automount可以理解三种不同的配置文件（称为映射）：直接，简介，主控映射。直接映射和简介映射提供了有关要自动挂载的文件系统信息。主控映射列出了automount应该注意的直接和简介映射。一次只有一个主控映射出于活动状态，默认的主控映射保存在/etc/auto.master
- 如果改变了主控映射或者它所援引的直接映射之一，那么就必须重新运行automount来读取改动，-v 显示它对自己的配置正在做的调整，-t 自动挂载的文件系统保持多久未用之后接卸载的时间（单位为秒）默认值通常是10分钟。
 - 间接映射文件，把几个文件系统自动挂载在同一个目录下。不过目录的路径在主控映射文件中设定，不需要在间接映射文件自身里设定。这个例子（或许保存在/etc/auto.harp文件里）
```
users 		vcl0000:/harp/users
devel -soft vcl0000:harp/devel
info  -ro	vcl0000:/harp/info
```
 - 直接映射文件，列出没有共同前缀的文件系统，描述自动挂载的文件系统的直接映射文件（/etc/auto.direct）
```
/usr/src vcl0000:/usr/src
/cs/tools -ro vcl0000:/cs/tools
```
automount知道该目录下子目录的内容被访问过之后才会显示它们（ls不能直接访问自动挂载目录的内容，所以不会让这些目录被自动挂载）
 - 主控映射文件，列出auto应该注意的直接和间接映射。对于每个间接映射文件，主控映射文件还制定了在该映射中定义的挂载文件所在的根目录。上栗所示的之间和间接映射文件的主控映射文件
```
/harp 	/etc/auto.harp -proto=tcp
/-		/etc/auto.direct
```
第一列是间接映射的本地目录名，或者特殊记号/-表示直接映射，第二列给出保存映射的文件。每种类型可有几个映射文件。如果一行的末尾制定了挂载选项，那么这些选项将成为该映射文件中所有挂载的默认选项。Linux一定要给NFSv4服务器指定`-fstype=nfs`这个标志

### sshfs
`sshfs vcl0000@vcl0000:/home/vcl0000 /home/jjh/vcl0000`挂载
`fusermount -u /home/jjh/vcl0000`卸载

## 共享系统文件
CIFS实质上是SMB的一个版本
### Samba
UNIX的CIFS服务器
Samba不仅童工CIFS提供文件服务，而且还能执行一个Windows主域控制器的所有基本功能，作为一个域控制器，Samba支持的高级特性如Windows域登录，Windows用户特性描述文件的漫游以及CIFS假脱机打印。
smbd nmbd
smbd实现文件和打印服务，还有验证和授权功能。nmbd提供别的CIFS主要部件：名字解析和服务声明。
smb.conf `/etc/samba/smb.conf` or `/etc/smb.conf`
`encrypt passwords = true`,windows客户机和Samba服务器之间交换的口令进行加密，这是默认选项。
smbpasswd来设置口令`sudo smbpasswd -a [userName]`,`smbpasswd -r smbserver -U [userName]`
smbclient命令行文件传输程序。
CIFS可以被mount挂载
`sudo mount -t cifs -o username=joe /path /mountPoint`
配置中的这个需要解开注释`browseable = yes`
`sudo /etc/init.d/samba restart`重启服务。
#### smbpasswd
`sudo smbpasswd jjh`

command|option
--|--
smbpasswd|-a 增加用户（要增加的用户必须以是系统用户）
smbpasswd|-d 冻结用户，就是这个用户不能在登录了
smbpasswd|-e 恢复用户，解冻用户，让冻结的用户可以在使用
smbpasswd|-n 把用户的密码设置成空.要在global中写入 null passwords -true
smbpasswd| -x  删除用户


## X Windows

远程桌面链接

remmina
remmina-plugin-drp
remmina-plugin-vnc



##
 Exapmle
- 重名
  - `ls *.jpg |awk -F "xx" '{print "mv "$0" "$1$2""}'|bash`剔除文件名中的xx
  - `for file in `ls *.jpg`;do mv $file `echo $file|sed 's/xx//g'`;done;`剔除文件名中的xx
  - `rename "xx" "" *.jpg`剔除文件名中的xx


## utils

### conv

#### html2dash
`html2dash.py -n quartz -i ./quartz/quartzEJS.png ./quartz -d /home/jjh/.local/share/Zeal/Zeal/docsets`

### mail
`sudo vi /etc/postfix/main.cf`




















end
