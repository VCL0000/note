# git

## 本地操作

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

### 操作流程

- 本地创建develop分支和远程develop分支关联`git chechkout -b develop origin/develop`
- 在develop分支上面，建一个子分支用于开发代码，并切换到该子分支`git checkout -b jjh`
- 修改代码后提交代码。`git commit -a -m "messages"`
- 切换回develop分支，将用户分支上的代码合并到develop分支`git checkout develop && git merge jjh`(将jjh分支上的代码合并到develop分支上)
- 将代码推送到远程develop分支`git push`，“git push <远程主机名> <本地分支名>:<远程分支名>”