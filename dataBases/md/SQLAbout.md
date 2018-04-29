## 函数

SELECT NOW();返回当前日期时间，db2x

分类|function|含义
-|-
字符串处理|RTRIM()|去右边空格
|LTRIM()|去左边空格
|TRIM()|去两边空格
|LENGTH()|字符串长度
|UPPER()|将字符串转换为大写
|LOWER()|将字符创装换为小写
数学运算|ABS()|返回一个数的绝对值
|COS()|返回一个角度的余弦
|EXP()|返回一个数的指数
|PI()|返回圆周率
|SIN()|返回一个角度的正弦
|SQRT()|返回一个数的平方根
|TAN()|返回一个角度的正切
聚合函数|AVG()|返回某列的平均值
|COUNT()|返回某列的行数
|MAX()|返回某列的最大值
|MIN()|返回某列的最小值
|SUM()|返回某列值之和

聚合不同值，`SELECT AVG(DISTINCT USER_AGE) FROM TEST.USER`，avg只处理不同的，相同的不做处理。


function|DB2|Oracle|MySQL|PostgreSQL|SQL server
-|-
字符串截取|SUBSTR()|SUBSTR()|SUBSTRING()|SUBSTR()|SUBSTRING()
类型装换|CAST()|使用多个函数|CONVERT()|CAST()|CONVERT()
获取当前日期|CURRENT_DTE|SYSDATE|CURDATE()|CURRENT_DTE|GETDATE()
||||||
||||||
||||||





























end
