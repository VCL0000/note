
### 将本地仓库上传github
没有sshKey的话需要创建并添加到github上，有的话直接添加就好了
在github上创建一个repository
`git remote add origin xxx.git`将git仓库和本地仓库进行关联
`git push origin master`将本地仓库的所有内容推送到远程仓库//空仓库要使用-u，-f为强制推送。

在github创建的时候选择创建README,会报一个`failed to push some refs to xx.git`的错，`git pull --rebase origin master`将内容合并。

ssh 免密 push
`ssh-keygen -t rsa -C "vcl0000@163.com"`生成相应的ssh秘钥
`~/.ssh/id_rsa.pub`公钥的位置，添加到github上。
`ssh -T git@github.com`，测试连通性
修改`.git/config`文件，将url改为ssh的地址。


`git checkout [fileName]`撤销从上次commit的修改
`git commit --amend`,修改提交信息
