[TOC]

# Linux Note
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
- `time commond` 命令运行的时间
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

## 文件系统
### 挂载/卸载文件系统
- `mount [directory | device ]`
挂载在某个特定系统上的文件系统清单保存在/etc/fstab文件中，当系统引导时，这个文件中的信息先被fsck再被自动mount
- umount卸载文件系统，大多数文件系统上上不能卸载处于繁忙(busy)状态的文件系统，在该文件系统中不能又任何打开的文件，也不能又任何进程的当前目录，文件系统若包含可执行程序那这些程序也不能处于运行状态。
- linux定义了一种lazy的卸载方式`umount -l`调用所有访问停止才能真正卸载，but不能保证当前访问都会自动关闭，其次半卸载会给使用文件系统的程序带来不一致（可以通过已有的文件句柄执行读写，却不能打开新的文件或者执行其他文件系统操作）
- `umount -f` 强制卸载一个处于繁忙状态的文件系统
- `fuser -c [mountpoint]` 查找该该挂载点文件系统上某文件或目录的每个进程的PID，再加一串字母显示反应状态, -v显示进程相关信息。`lsof`比fuse更先进更复杂
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

## 用户
### `/etc/passwd`

- `/etc/passwd`文件是系统能识别的用户的一份清单，but能够被目录服务扩展或替代，所以只有在单机系统上才是完整权威的。
- 一个代表一个用户，共有七个字段用:分隔
登录名:加密的口令或占位符:UID:GID:GECOS信息:主目录:登录shell
- 加密口令实际被保存在`/etc/shadow`。散列+salt加密。MD5的口令以$md5$开头，SHA256以$5$开头
- 可以编辑该文件创建新账号(vipw),加密口令位不要为空否则不用口令就能访问这个账号
- 加密口令的算法在`/etc/login.defs`中设置

- **添加用户**
`adduser username`
`passwd username`
`groupadd groupname`
- **新建用户同时增加工作组**
`useradd -g groupname username`
- **用户追加到组 没有a用户将从原来的组中移除**
`usermod -a -g group user`
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


## 包管理

### apt-get 依赖问题

- 强制安装依赖 apt-get -f install
- 备份/var/lib/dpkg/info
- rm /var/lib/dpkg/info
- mkdir /var/lib/dpkg/info
- apt-get install package

### apt-get 清理包

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

### dpkg
选项|含义
---|---
-i|安装
-r|卸载
-P|--purge
-l|list
-S file|查找拥有该文件的包

### rpm
```
-ivh 安装
-U 升级
-e 卸载
-qa 查询
```

### alien
```
alien -d package.rpm
alien -r package.deb
```
### ldd
`ldd commondPath`列出所有所需的运行时库
