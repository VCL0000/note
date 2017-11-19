
#docker


# UI
## DockUI
docker run -d -p 59000:9000 --privileged -v /var/run/docker.sock:/var/run/docker.sock uifd/ui-for-docker
## Shipyard
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock shipyard/deploy start
Open your browser to http://<dockerd host ip>:8080, username: admin, password: shipyard
# 运行容器

## 容器相关命令
`docker info`docker 信息

### 运行容器

`docker run`
command|x
-|-
-i|标准输入
-t|伪tty
-d|守护进程
-p [port]  |  49153~65535选择一个比较大的端口映射到容器的[port]端口上
-p [ip]:[localPort]:[port]  |  将本地ip以及端口映射到容器上 `docker port`
-v [localpath]:[containerPath]  |  将宿主机目录当做卷挂载到容器里
--link <name or id>:alias  |  容器之间通信不向宿主机开放端口

- docker run -d --name redis vcl0000/redis
- docker run -p 4567 --name webapp --link redis:db -it -v $PWD/webapp:/opt/webapp vcl0000/sinatra /bin/bash
- `docker run -it ubuntu /bin/bash`本地没有下载 /bin/bash 容器中运行的命令

`docker ps`
command|x
---|---
`docker ps`|正在运行的容器
`docker ps -a`|容器列表
`docker ps -l`|最后一次运行的容器（在运行的和已停止的）

### 容器重命名
`docker --name [name] -it ubuntu /bin/bash`
### 启动停止容器
`docker start [container_name]`
`docker start [uuid]`
`docker stop [uuid]`
`docker kill [uuid]`
`docker stop $(docker ps -anq)`停止全部镜像
### 附着到容器的会话
`docker attach [uuid]`
`docker attach [container_name]`
### 查看日志
`cokder logs`
command|x
-|-
-- tail  |  同tail
-t  |  时间戳
### 容器内进程
`cokder top [uuid]`查看容器内进程
`docker exec [-d/-ti] [uuid] [command]`容器内部运行进程
### 自动重启容器
`docker run --restart=always`总是重启
`docker run --restart=on-failure:n`退出码为n时重启
### 删除容器
`docker inspect [uuid]`相对ps更详细的容器信息
`docker rm [uuid]` 删除容器（运行中的无法删除）
docker rm `docker ps -aq`删除所有镜像

# 镜像

##
`docker images`列出镜像
本地镜像都保存在`/var/lib/docker`
镜像保存在仓库，仓库保存在registry。
默认的远程registry`https://hub.docker.com/`
`docker pull [ubuntu]`拉取镜像
一个仓库的镜像可以通过tag来区分centos:7
顶级仓库和用户仓库，顶级仓库docker公司维护，用户仓库[userName]/[仓库名]
查找镜像`docker search [name]`
`docker push [userName]/[registryName]`推送镜像
`docker rmi [UUID]`删除镜像
可以和gitHub之类搞在一起自动构建
自己的registry
`docker run -p 5000:5000 registry`从容器运行registry
先打tag后push
`docker tag [UUID] [host]:[port]/[userName][registryName]`
`docker push [UUID] [host]:[port]/[userName][registryName]`
### 仓库镜像
```
vi /etc/docker/daemon.json
{
“registry-mirrors”: [“https://registry.docker-cn.com“]
}
```
重启生效
## 构建镜像
`docker login`登录

### commit
更改容器后
`docker commit [uuid] [name]`
`docker commit -m="提交信息" --author="" [uuid] [userName/regstryName:tag]`
### Dockerfile

```
# version: 0.0.1
FROM ubuntu:16.04
MAINTAINER jjh "vcl0000@163.com"
RUN apt-get update
RUN [ "apt-get", "install", "-y", "nginx" ]
RUN echo 'Hi container' > /usr/share/nginx/html/index.html
EXPOSE 80
```
`docker build -t "vcl0000/static_web:v1" .` 用户、镜像名：tag DockerfilePath。DockerfilePath可以是一个git地址

- `#`开头的注释
- `FROM` 指定了一个已经存在的镜像作为base image，之后都操作都是在次基础上。
- `MAINTRINER`作者和邮箱
- `RUN`使用`/bin/sh -c`执行，还支持`RUN [ "apt-get", "install", "-y", "nginx" ]`数组的形式传递参数，
- `EXPOSE`向外开放多个端口。
- 没有做过修改的步骤会被当做缓存
build 的 `--no-cache`参数可以跳过缓存
`ENV REFRESHED_AT 2017-07-01`设置构建时的变量
`CMD ["/bin/bash", "-l"]`启动时执行的命令，docker run 指定的命令会覆盖CMD
`ENTRYPOINT`同CMD但是 docker run 的指定参数会被当做参数传递进去
`WORKDIR`构建时容器内部的工作目录
`USER`该镜像以是什么样的用户运行，默认是root 可以在docker run 通过 -u选项覆盖
`VOLUME`向基于镜像创建的容器添加劵
`ADD http://wordpress.org/latest.zip /root/wordpress.zip` 将构建环境下的文件和目录复制到镜像中，在使用归档文件时会自动解开，原文件的位置可以是URL，只能添加构建目录或上下文中的文件。 `/`结尾为目录
`COPY` 不会解压，本地文件需要和Dockerfile放到同一目录下，路径需要是绝对路径，UID GID会被设置为0
`ONBUILD ADD . /app/src`当一个镜像被其他镜像做基础镜像时将会执行。

































end
