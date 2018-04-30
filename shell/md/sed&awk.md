[TOC]

# sed & awk

## sed

### 概述
- sed一次处理一行（打印一行）
- 不改变原文件

### 格式

命令行格式 sed \[options\] 'command' file(s)
- options: -e(使用多个命令);-n(不产生命令输出，使用print命令完成输出（p）)
- command:行定位（正则）+sed命令（操作）
  - 'p',打印`sed -n 'p' /etc/passwd`

脚本格式 sed -f scriptFile file(s)

### 匹配

***行号和正则***
行号匹配`nl /etc/passwd|sed -n '10,20p'`打印10-20
正则匹配`sed -n '/root/,/jjh/p' /etc/passwd`正则“root”-“jjh”的行。正则需要使用`//`包裹。
取反`nl /etc/passwd |sed -n '10!p'`不包括第10行
`nl /etc/passwd |sed -n '10,20!p'`不包括10-20
跳行 sed first~step`nl /etc/passwd |sed -n '1~3p'` 输出一行跳三行

### 基本操作命令
- a 新增行/-i 插入行
  - `nl /etc/passwd | sed '5a ######'`第五行下增加一行,`nl /etc/passwd | sed '1,5i ######'`第一行到第五行前增加一行
- c 替代行
  - `nl /etc/passwd | sed  '55c ######'`将第55行替换为,`nl /etc/passwd | sed  '5,55c ######'`将5-55替换为一行
- d 删除行
  - `nl /etc/passwd | sed  '54d'`删除第54行
- s 替换
  - `sed 's/false/true/' /etc/passwd`false替换为true，一行替换一次，
- g 全局
  - `sed 's/:/%%/g' /etc/passwd`全局替换，行内全部替换
#### 实例
`sed '$a zzz' /etc/passwd`文本尾行追加
`echo "\n\n\n"|sed '/^$/d'`删除空行
`sed -n '/WARN/p' transmission.log`查找日志中的WARN行
`sed '{/^$/d;/\ /d;/\t/d;}' /etc/passwd`删除空行，空格，制表符。
`sed '{s/^/<a href=/g;s/$/\>link<\/a>/g}' 02url.txt>02.html`行首行尾增加。

### 高级操作命令
- `{}` 多个命令，使用`;`分隔
  - `nl /etc/passwd| sed  '{20,30d;s/false/true/g}'`删除20-30行\&替换false为true
- n 跳行
  - `nl /etc/passwd | sed -n '{n;p}'`跳行打印（2468）` nl /etc/passwd | sed -n '{p;n}'`打印 跳行（13579）同`sed -n '1~2'p`
- & 匹配到的字符
  - `sed 's/^[a-z_-]\+/& /g' /etc/passwd`匹配到的用户名后加空格
- U/L/u/l
  - `sed 's/^[a-z_-]\+/\U& /g' /etc/passwd` 匹配到的用户名大写 U单词大写,L单词小写,u首字母大写,l首字母小写
- () 提取匹配的字符串
  - `sed 's/\([1-9]\)'/\1/ file`//中正则匹配到内容，()内的正则匹配到的提取到1里。
  - `sed 's/\(^[a-z1-9_-]\+\):.*$/\1/' /etc/passwd`第用户名`sed 'sed 'sed 's/\(^[a-z1-9_-]\+\):x:\([0-9]\+\):\([0-9]\+\):.*$/user:\1 UID:\2 GID:\3/' /etc/passwd`用户名 uid gid
- r 复制指定文件插入到匹配行
  - `sed '1r 123.txt' abc.txt` 从abc.txt中读取一行之后是123.txt的内容，再然后是abc.txt剩余的内容
- w 复制匹配行拷贝到指定文件里
  - `sed '1w abc.txt' 123.txt` 从123.txt复制一行到abc.txt中。abc.txt文件发生改变。
- q 退出sed
  - `nl /etc/passwd|sed '10q'`读取10行后退出，`sed '/jjh/q' /etc/passwd`读取到jjh退出
### 实例
`sed 's/string1/string2/g'`替换 string1 为 string2
`sed -i 's/wroong/wrong/g' *.txt`用 g 替换所有返回的单词
`sed 's/\(.*\)1/\12/g'`修改 anystring1 为 anystring2
`sed '/<p>/,/<\/p>/d' t.xhtml`删除以 <p> 开始,以 </p> 结尾的行
`sed '/ *#/d; /^ *$/d'`删除注释和空行
`sed 's/[ \t]*$//'`删除行尾空格 (使用 tab 代替 \t)
`sed 's/^[ \t]*//;s/[ \t]*$//'`删除行头尾空格
`sed 's/[^*]/[&]/'`括住首字符 [] top -> [t]op
`sed = file | sed 'N;s/\n/\t/' > file.num` 为文件添加行号

## awk

### 概述

一次处理一行内容
对每行可以切片处理

### 格式

- 命令行格式 awk [options] 'command' file(s)
  - command :pattern {awk操作命令}，pattern：正则表达式;逻辑判断式。多个操作用;分隔
- 脚本格式 awk -f awk_script_file file(s)

#### options

- -F ':' 指定分隔符末认为空格

#### 扩展格式

BEGIN{print "start"} pattern {commands} END{print "end"} BEGIN行循环开始前，END行循环结束后。可用户变量初始化，制表时的表头
- `awk -F ':' 'BEGIN {print "start"} $3==100{print $1} END{print "end"}' /etc/passwd`
- `awk -F ':' 'BEGIN {print "line col user"}{print NR,NF,$1}{print FILENAME}' /etc/passwd`
### 内置参数

- $0 当前行
- $1 每行第一个字段
- NR 行号
- NF 字段总数
- FILENAME 正在处理的文件名

### 逻辑判断式
- ~ !~ 匹配正则表达式
  - $1匹配正则`awk -F ':' '$1~/^m.*/{print $1}' /etc/passwd` 首字母为m的用户名
  - `awk -F ':' '$1!~/^m.*/{print $1}' /etc/passwd`首字母不为m的用户名
- == != < > 判断逻辑表达式
  - `awk -F ':' '$3<100{print $1}' /etc/passwd`UID小于100的用户名

### 使用外部变量

- `echo | awk -v var="BASH" '{print var}'`
- `var="BASH";echo|awk '{print var}' var="$var"`

### 实例

- `awk -F ':' '{print $1,$3}' /etc/passwd` 打印：分隔的第一个字段和第三个字段。
- ` awk -F ":" '{printf("line:%s col:%s user:%s \n", NR,NF,$1)}' /etc/passwd`格式化打印行号，行字段个数，用户名。
- `awk -F ':' '{ if ($3>100) print $1}' /etc/passwd`uid大于100的用户名。
- `sed -n '/Error/p' /etc/passwd | awk -F ':' '{print $1}'` 配合sed查找后打印。
- `awk -F ':' '/jjh/{print $1}' /etc/passwd
`匹配后打印。
- sum`ls -l |awk 'BEGIN{size=0}{size+=$5}END{print "size is " size/1024/1024"M"}'`目录文件夹大小
- 条件 count`awk -F ':' 'BEGIN{size=0} {if ($3>100) size++} END{print size}' /etc/passwd` uid大于100的用户数
- 递增行号，以行号为索引的数组，遍历数组`awk -F ':' 'BEGIN{count=0} {if ($3>100) name[count++]=$1} END{for(i=0;i<count;i++)print i,name[i]}' /etc/passwd`
