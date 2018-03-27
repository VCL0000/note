<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Linux Note](#linux-note)
	- [man](#man)
	- [Centos](#centos)
		- [网络开机自动](#网络开机自动)
		- [修改yum源](#修改yum源)
	- [About Package](#about-package)
		- [ORACLE](#oracle)
		- [MQ](#mq)
			- [WASMQ](#wasmq)
		- [jdk](#jdk)
			- [环境变量](#环境变量)
			- [多版本](#多版本)
		- [vim](#vim)
		- [zsh](#zsh)
		- [uget](#uget)
		- [maven](#maven)
		- [redis](#redis)
		- [samba](#samba)
		- [trans 翻译](#trans-翻译)
		- [db2](#db2)
			- [package](#package)
			- [db2 install](#db2-install)
			- [ab2 about commond](#ab2-about-commond)
			- [卸载db2](#卸载db2)

<!-- /TOC -->

# Linux Note
---
## man
man –k xx  *匹配为xx的命令*
**Linux手册页的内容区域**

区域号|所涵盖的内容
---|---
1|可执行程序或shell命令
2|系统调用
3|库调用
4|特殊文件
5|文件格式与约定
6|游戏
7|概览、约定及杂项
8|超级用户和系统管理员命令
9|内核例程

节|描述
---|---
Name|显示命令名和一段简短的描述
Synopsis|命令的语法
Confi|guration命令配置信息
Description|命令的一般性描述
Options|命令选项描述
Exit|Status命令的退出状态指示
Return|Value命令的返回值
Errors|命令的错误消息
Environment|描述所使用的环境变量
Files|命令用到的文件
Versions|命令的版本信息
Conforming|To命名所遵从的标准
Notes|其他有帮助的资料
Bugs|提供提交bug的途径
Example|展示命令的用法
Authors|命令开发人员的信息
Copyright|命令源代码的版权状况
See|Also与该命令类型的其他命令



## Centos

### 网络开机自动
`vi /etc/sysconfig/network-scripts/ifcfg-ethxxx`
ONBOOT="no" 改为yes

### 修改yum源

- **挂载镜像**
`mkdir /mnt/cdrom`
`mount -t auto /dev/cdrom /mnt/cdrom`
- **修改本地源中的路径至镜像，优先是从网络。**
`/etc/yum.repos.d/`
`CentOS-Base.repo 是yum 网络源的配置文件`
`CentOS-Media.repo 是yum 本地源的配置文件`
- **备份**
`mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup`
- **下载163的yum源配置文件**
`wget http://mirrors.163.com/.help/CentOS6-Base-163.repo`
- **运行yum makecache生成缓存**


## About Package

### other
npm install gitbook-pdf -g

### ORACLE

`export NLS_LANG=AMERICAN_AMERICA.UTF8`
**启动TNS监听**
`lsnrctl start/stop`
`sqlplus / as sysdba`
`startup/shutdown`
`create user c##vcl0000 identified by 106514;`
`grant dba to c##vcl0000;`CONNECT
`--ALTER USER c##test identified by test;`
`--DROP USER c##test`


### MQ

#### WASMQ
Runtime,SDK,Server,Client,Samples,Explorer.
passwd mqm

### jdk

#### 环境变量

`export JAVA_HOME=/usr/local/bin/java/jdk1.8.0_131`
`export JRE_HOME=.:${JAVA_HOME}/jre`
`export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib`
`export PATH=${PATH}:${JAVA_HOME}/bin`

#### 多版本
- 输入sudo update-alternatives --display java
可查看信息默认的jdk信息，刚开始因为没有，提示错误：no alternatives for java
- `sudo update-alternatives --install /usr/bin/java java`  你JDK的路径/java  300(优先级)
- `sudo update-alternatives --install /usr/bin/javac javac`  你JDK的路径/javac  300(优先级)
若有多个版本，需要修改默认的，则输入
- `sudo update-alternatives --config java`
- `sudo update-alternatives --config javac`
将会提示：要维持当前值[]请安回车键或者输入选择的编号输入自己设置的优先级的编号(300)，按回车就可以了
- `sudo update-alternatives --display java`
-
git clone  https://github.com/powerline/fonts
./install.sh
sudo fc-cache -fv

### 安装字体
`/usr/share/fonts/` 字体的目录，目前不清楚是怎么配置到这里的
`$HOME/.local/share/fonts`，powerline 是配置在这里的
`fc-cache -fv $HOME/.local/share/fonts`
### vim
- **插件管理器**
  - mkdir -p ~/.vim/bundle
  - git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
- **配置.vimrc**
```
set nocompatible              " 这是必需的
filetype off                  " 这是必需的
" 你在此设置运行时路径
set rtp+=~/.vim/bundle/Vundle.vim
" vundle初始化
call vundle#begin()
" 这应该始终是第一个
Plugin 'gmarik/Vundle.vim'
```
- **管理插件**
  - `:PluginInstall [plugin-name]`
  安装在.vimrc文件中列出来的所有插件。还可以只安装某一个特定的插件，只要传递其名称。
  - :BundleClean
  清除列表中没有的插件
  - :BundleInstall
  安装列表中全部插件
  - :BundleList
  列举出列表中(.vimrc中)配置的所有插件

  - 移除插件
  编辑.vimrc文件移除要移除的插件行
  :PluginClean

- **显示美化**
```
set rtp+=/usr/local/lib/python4.5/dist-packages/powerline/bindings/vim
set guifont=Monaco\ for\ Powerline:h14.5
set laststatus=2
let g:Powerline_symbols = 'fancy'
set encoding=utf-8
set t_Co=256
set number
set fillchars+=stl:\ ,stlnc:\
set term=xterm-256color
set termencoding=utf-8
syntax enable
if has('gui_running')
  set background=light
else
  set background=dark
endif
colorscheme solarized
//这个主题需要clone到vundle目录下line
```

### zsh
- `pip install powerline-status`
- `pip show powerline-status`
- //.zshrc中添加
- `. /usr/local/lib/python3.5/dist-packages/powerline/bindings/zsh/powerline.zsh`


### uget
FlashGot
uget aria2
```
sudo add-apt-repository ppa:slgobinath/uget-chrome-wrapper
sudo apt update
sudo apt install uget-chrome-wrapper
https://chrome.google.com/webstore/detail/uget-integration/efjgjleilhflffpbnkaofpmdnajdpepi/related
```
### maven
`export MAVEN_HOME=/usr/local/bin/apache-maven3`
`export PATH=${PATH}:${MAVEN_HOME}/bin`

### redis

`make && make install`
`util/install_server.sh`
```
Port           : 6379
Config file    : /etc/redis/6379.conf
Log file       : /var/log/redis_6379.log
Data dir       : /var/lib/redis/6379
Executable     : /usr/local/bin/redis-server
Cli Executable : /usr/local/bin/redis-cli
```

### samba
```
sudo /etc/init.d/smbd restart//重启
sudo vi /etc/samba/smb.conf//homes下的注释解开 browseable = yes
sudo smbpasswd -a vcl0000//添加用户
```

### trans 翻译
- git clone https://github.com/soimort/translate-shell
- cd translate-shell
- make
- sudo make install

### nvidaia
`sudo vi /etc/modprobe.d/blacklist-modem.conf `
add line
`blacklist nouveau option nouveau modeset=0`
`sudo update-initramfs -u` 不知道不敲可不可以


### db2

#### package

- DB2 Express-C-db2_v101_linuxx64_expc.tar.gz
- db2/expc/db2setup
- National Language Pack for DB2-db2_v101_linuxx64_nlpack.tar.gz
- db2/nlpack
- Data Studio Administation Client-bm_ds4120_lin.tar.gz
- db2/disk1/InstallerImage_linux64/install#安装管理器和DataStudio

#### db2 install

- DAS(DB2 Administration Server)
dasusr1
- Instance Owner(实例用户所有者)
db2inst1
- 受防护的用户
db2fenc1
- db2sampl
创建sample数据库

#### ab2 about commond

- **自启动**
`db2iauto -on/off [实例名]`
- **DAS服务器的关闭和开启需要切换到DAS用户下执行**
`/opt/ibm/db2/V10.1/das/bin/db2admin stop 或 /opt/ibm/db2/V10.1/das/bin/db2admin start`
- **创建实例：**
`sudo /opt/ibm/db2/V10.1/instance/db2icrt-u db2fenc1 db2inst1`
- **创建Sample数据库的命令为：**
`db2sampl`
- **显示所有数据库实例的命令是**
`db2ilist`
- **显示当前数据库实例的命令是**
`db2 get instance`
- **启动停止实例**
`db2start/db2stop`

#### 卸载db2

1. 首先删除数据库
* su - db2inst1
* db2 list db directory
* db2 drop db <db name>
2. 其次删除实例
* su - root
* cd <db2 dir>/instance
* ./db2ilist
* ./db2idrop -f <instance name>
3. 然后删除das
* su - root
* cd <db2 dir>/instance
* ./daslist
* ./dasdrop <das user>
4. 再卸载数据库安装介质
* su - root
* cd <db2 dir>/install
* ./db2_deinstall -a
5. 最后删除用户( db2inst1,db2fenc1,dasusr1)
* userdel -r <username>
