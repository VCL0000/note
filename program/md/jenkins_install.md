
## 安装
#### 安装包
* jenkins.war
* jenkins.deb
  * installed bin whereis /usr/share/jenkins

#### 启动
* jar -jar jenkins.war or webapps
* service jenkins start

#### 配置文件
* ~/.jenkins/
* /var/lib/jenkins/

#### 初始化

    localhost:8080\jenkins
      initPasswd  ~/.jenkins/secrets/initialAdminPassword
    localhost:8080\
      选择plugin，设置用户
      系统管理 -> Global Tool Configuration

### 插件
  * Maven Integration plugin
    * create Maven project
