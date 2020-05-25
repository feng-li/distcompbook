Hive 安装运行
=============

Hive 的安装同样是在上面配置的集群上进行，具体步骤如下：

准备
----

安装MySQL:

        $ sudo apt-get install mysql-server mysql-client

安装成功后，进入mysql创建一个数据库

-   建立数据库hive，并设定为latin1编码，否则出错

            mysql> create database hive default character set latin1;

-   创建用户hive

            mysql> create user 'hive'@'%' identified by 'hive';

-   给hive用户授权

            mysql> grant all privileges on hive.* to hive@'%'  identified by 'hive';

安装Hive
--------

我们选择下载hive-0.8.1下载地址为

首先把把hive-0.8.1.tar.gz复制到/usr/local，同时解压hive-0.8.1.tar.gz与重命名

        $ tar -zxvf hive-0.8.1.tar.gz
        $ sudo mv hive-0.8.1 /usr/local/hive

接下来修改.bashrc文件。

        $ sudo vim ~/.bashrc

在里面增加:

        export HIVE_HOME=/usr/local/hive
        export PATH=$PATH:${HIVE_HOME}/bin

保存并退出，执行修改的文件:

        $ source ~/.bashrc

配置Hive
--------

首先修改conf目录下的模板文件，将hive-env.sh.template重命名为 hive-env.sh，将hive-default.xml.template重命名为
hive-site.xml。

        $ cd /usr/local/hive/conf
        $ mv hive-env.sh.template hive-env.sh
        $ mv hive-default.xml.template hive-site.xml

这时就可以启动Hive了

        $ hive

进入Hive窗口，在下面测试语句，在hive 中建立表 test

        hive> create table test (key string);
        hive> show tables;

如果出现： `OK test Time taken: 0.153 seconds`

说明Hive 已经在集群中正确安装。
