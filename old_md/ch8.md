Mahout 安装与运行
=================

Mahout下载网站为该路径中包含了Mahout的各种版
本，可以选择自己合适的版本。在这里，我们用的是mahout-distribution-0.9。

将下载后的mahout压缩文件放在你所选定的路径下（本文默认是/home/dmc），并执行以下命令解压缩：

        $ tar -zxvf mahout-distribution-0.9.tar.gz

这样，Mahout安装文件就保存到了路径下。

环境变量可以保存在包括系统级和用户级多个配置文件中，我们仍将这些变量保存在
了`.bashrc`中，如下所示：

配置Mahout环境变量

        export MAHOUT_HOME=/home/dmc/mahout-distribution-0.9
        export MAHOUT_CONF_DIR=$MAHOUT_HOME/conf
        export PATH=$MAHOUT_HOME/conf:$MAHOUT_HOME/bin:$PATH

配置Hadoop环境变量，如果安装Hadoop的时候已经配置好，这一步就不用再进行了。

        export HADOOP_HOME=/home/dmc/hadoop/hadoop-2.4.0
        export HADOOP_CONF_DIR=$HADOOP_HOME/conf 
        export PATH=$PATH:$HADOOP_HOME/bin
        export HADOOP_HOME_WARN_SUPPRESS=not_null

接下来执行命令mahout，就可验证Mahout是否安装成功。
