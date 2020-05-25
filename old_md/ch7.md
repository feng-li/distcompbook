Hadoop 安装运行
===============

单机伪分布式安装
----------------

Hadoop在数据相关企业生产中已经普遍存在，其安装调式也相对简单。Hadoop的运行支持各个常见的计
算机平台和操作系统。GNU/Linux是产品开发和运行的平台。
Hadoop已在有2000个节点的GNU/Linux主机
组成的集群系统上得到验证。这部分提供了Hadoop的一个简单安装入门，帮助你快速完成单机上
的Hadoop安装与使用以便你对Hadoop分布式文件系统(HDFS)和MapReduce框架有所体会，比如在HDFS上
运行示例程序或简单作业等。我们简单介绍Hadoop在Ubuntu
Linux下的安装，Hadoop在其他平台的安装 请参考Apache Hadoop官方安装指南()

### 所需软件

-   Java JDK 必须安装，建议的Java版本可以在Hadoop 维基页面 （）中找到。

-   `ssh` 必须安装并且保证 `sshd`一直运行，以便用Hadoop
    脚本管理远端Hadoop守护进程。

如果你的计算机没有安装这些软件，可以按照以下方式安装

        $ sudo apt-get install ssh
        $ sudo apt-get install rsync
        $ sudo apt-get install openjdk-7-jdk

为了方便Hadoop访问，如果你的ssh没有配备密钥，请为你的计算机生成一组密钥

        $ ssh-keygen -t rsa

并将其加入本机的认证列表里，

        $ cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

这样可以保证以后每次启动Hadoop时不用手动输入密码。

### 安装调式Hadoop

如果以上工作准备就绪，就可以到Hadoop官方网站
()下载最新版本的二进制程序。将下载下来的
Hadoop二进制文件解压缩到本机。在所在的文件夹里，找到文件，
用文本编辑器打开，设置本机Java路经。

    export JAVA_HOME=/usr/lib/jvm/default-java

如果不确定Java的安装路径，可以通过以下类似的命令查找。

        $ locate default-java | grep jvm

接下来就可以通过以下命令运行Hadoop了。

        $ <hadoop-home>/bin/hadoop

其中`<hadoop-home>`为Hadoop二进制包所在的位置。

### 伪分布式操作

在单机安装Hadoop后，Hadoop可以被配置为伪分布式模式，这非常有利于在单机上调式分布代码。

编辑Hadoop配置文件

        <configuration>
            <property>
                <name>fs.defaultFS</name>
                <value>hdfs://localhost:9000</value>
            </property>
        </configuration>

Hadoop启动以后就可以通过浏览器地址访问HDFS文件。

编辑Hadoop配置文件

        <configuration>
            <property>
                <name>dfs.replication</name>
                <value>1</value>
            </property>
        </configuration>

可以设置DFS文件冗余，这里的1表示存储数据的份数。

### 本地运行Hadoop作业

接下来就可以在本地启动Hadoop系统了。启动Hadoop系统首先需要对HDFS文件系统格式化。

        $ bin/hdfs namenode -format

当启动完成时，可以启动NameNode守护进程和DataNode守护进程

        $ sbin/start-dfs.sh

Hadoop启动后，各个守护进程的日志文件会被记录在Hadoop日志文件夹，默认的是Hadoop安装目录下的
logs文件夹。

接下来可以在HDFS建立一个个人目录，这样MapReduce任务所需要的数据和结果就可以存在该目录下了。

        $ bin/hdfs dfs -mkdir /user
        $ bin/hdfs dfs -mkdir /user/<username>

### 单机YARN的操作

如果你成功完成以上步骤，经过简单的配置，MapReduce任务就可以在YARN运行。

首先配置文件，

        <configuration>
            <property>
                <name>mapreduce.framework.name</name>
                <value>yarn</value>
            </property>
        </configuration>

和文件

        <configuration>
            <property>
                <name>yarn.nodemanager.aux-services</name>
                <value>mapreduce_shuffle</value>
            </property>
        </configuration>

接下来就可以启动ResourceManager守护进程和NodeManager守护进程。

        $ sbin/start-yarn.sh

默认的ResourceManager的网页界面可以通过

这样就可以开始运行MapReduce任务了。

当任务结束，就可以停止所有的守护进程了。

        $ sbin/stop-yarn.sh

全分布式集群
------------

Hadoop可以被配置在高性能集群上，目前常见的数据处理机构均有配置完善的Hadoop集群使用。本节简
单描述全分布式的集群安装。感兴趣的读者请访问Hadoop的官方文 档
，或者相关文献。

Hadoop
的伪分布式安装比较简单，但是对于集群来说需要将每个机器进行配置，过程比较繁琐，但是并
不困难。在官网上有详细的安装资料（）。在安装集群之前，
建议读者先去梳理一下伪分布式的安装，相对伪分布式而言，Hadoop
的集群安装便是完全分布式
安装。本节所示实例的硬件是六台电脑（当然了最好是两台及其以上），主节点（master）
操作系统是64位的Ubuntu server 14.04 LTS(),五台次节点（slave）
是64位的Ubuntu Desktop 14.04.3 LTS ()

### 安装前的准备

在安装前我们一般要先确定好我们集群的规模和选用哪台机器作为我们的master
和那台机器作为我们 的slaves 。正如上文所说，我们主节点系统采用Ubuntu
14.04 server（64位）版，5台slaves 机器采 用Ubuntu 14.04 Desktop
（64位）版，如果系统是32位也同样适用。我们的集群是基 于hadoop 2.7.0。

我们选master用户名作为master（集群主机）（即IP 地址为211.71.20.246
），然后在该主机
的 `/etc/hostname` 中，修改机器名为master，将其他主机分别改 为`dmc001`,
`dmc002`, `dmc003`, `dmc004`,
`dmc005`(名字不唯一，可按照自己的标准设置，具体在系统安装时就可
以设置好)。接着把 `/etc/hosts` 中的信息复制到集群的所有机器上去。

我们是使用搭建集群的机器，主机名与IP地址对应如下：

        211.71.20.246 master
        211.71.20.201 dmc001
        211.71.20.202 dmc002
        211.71.20.203 dmc003
        211.71.20.204 dmc004
        211.71.20.205 dmc005

将上面的主机与IP的对应信息配置到每台机器的/etc/hosts 文件上：

        $ sudo vim /etc/hosts

为了我们便于操作的修改，建议将所用用户账号和用户组变成hadoop,同时赋予管理员权限，具体的步骤是：

        $ sudo adduser hadoop
        $ sudo vi  /etc/sudoers

在编辑窗口添加：

        hadoop ALL=(ALL:ALL) ALL

### 更新软件源和安装必要的软件

首先在确保所有机器联网的情况下更新软件源

        $ sudo apt-get update

然后安装编辑器 一般情况下，系统会自带vi
编辑器，如果读者不熟，建议安装下vim 编辑器，如果方 便也可以使用winscp
自带的编辑器（这里默认读者远程操作系统的配置），命令是：

        $ sudo apt-get install vim

和单机安装类似，集群安装需要在每台机器上需要安装SSH
server、配置SSH无密码登陆。输入以下命令：

        $ sudo apt-get install openssh-server

安装完成后，可以试验下登陆本机命令：

        $ ssh localhost

此时会有提示，需输入
yes。然后按提示输入该用户的密码，这样就登陆到本机了。这里有一个问题就是每
次ssh 都需要输入一次密码，这给Hadoop
的集群操作带来很大的问题，即每次运行Hadoop都需要用户输
入所有节点的密码。为解决这个问题，我们下面设置无密码登陆。利用
ssh-keygen 生成密钥，并将密 钥加入到授权中，首先进入目录，输入：

        $ cd ~/.ssh/

然后获取密钥：

        $ ssh-keygen -t  rsa

一路回车下去，最后会生成密钥，

将生成的密码加入授权：

        $ cat id_rsa.pub >> authorized_keys

这样密码就授权到 了，这样再次输入（ssh master ）就不会再允许输入密
码了。

通过ssh 无密码登陆各节点需要将刚才生成的新的 复制到集群中的其他节
点中,使用下面的命令：

        $ sudo scp ~/.ssh/authorized_keys  dmc@dmc001:/home/dmc/.ssh
        $ sudo scp ~/.ssh/authorized_keys  dmc@dmc002:/home/dmc/.ssh
        $ sudo scp ~/.ssh/authorized_keys  dmc@dmc003:/home/dmc/.ssh
        $ sudo scp ~/.ssh/authorized_keys  dmc@dmc004:/home/dmc/.ssh
        $ sudo scp ~/.ssh/authorized_keys  dmc@dmc005:/home/dmc/.ssh

在主节点复制完文件后，查看是否可以无密码登录：

        $ ssh dmc001

第一次按提示，输入yes 就无密码登录到dmc001 机器了。然后退出：

        $ logout

依次试验剩余的每个节点。这样就实现每个节点的无密码登录了。

正如前面的Hadoop
伪分布式设置一样，我们这里仍然采用较便捷的方式，在主节点和次节点同时进行
下面的操作：

        $ sudo apt-get install openjdk-7-jre openjdk-7-jdk

在安装的过程中，如果出现
这样的提示错误，说明可能是有另外一个程序正在运行，导致
资源被锁不可用。而导致资源被锁的原因，可能是上次安装时没正常完成，而导致出现此状况。解决方
法,输入以下命令:

        $ sudo rm /var/cache/apt/archives/lock
        $ sudo rm /var/lib/dpkg/lock

所有机器都安装完后，可以查看Java 安装的版本：

        $ java –version

下面根据安装的Java 路径设置环境变量。首先获取Java 默认安装路径

        $ whereis java

然后就可以设置

        $ vim ~/.bashrc

在文件首行输入上一条命令得到的Java 路径：

        export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

最后为了使 JAVA 的环境变量生效，需要执行以下操作

        $　source ~/.bashrc

### 安装及配置Hadoop

这里我们将Hadoop 安装在 目录下，具体的配置可参考附录的Hadoop 单机/伪分布
式安装。我们现在master
上进行配置，然后将配置文件复制到其他节点的相同位置就可以。与上面的配
置不同的是，完全分布式模式需要修改 中的5个配置文件，后四个文件可点击查
看官方默认设置值，这里仅设置了正常启动所必须的设置 项： 几个文件

#### 修改配置slaves

        $ cd /usr/local/hadoop/etc/hadoop
        $ vim slaves

输入：

        dmc001
        dmc002
        dmc003
        dmc004
        dmc005

#### 修改配置文件`core-site.xml`

在`<configuration> </configuration>`在中间添加如下内容：

        <property>
            <name>io.native.lib.available</name>
            <value>true</value>
        </property>

        <property>
            <name>fs.default.name</name>
            <value>hdfs://master:9000</value>
            <description>The name of the default file system.Either the literal string "local" or a host:port for NDFS.</description>
            <final>true</final>
        </property>

        <property>
            <name>hadoop.tmp.dir</name>
            <value>/tmp</value>
        </property>
        <property>
            <name>dfs.replication</name>
            <value>1</value>
        </property>

        <property>
            <name>mapred.job.tracker</name>
            <value>hdfs://master:9001</value>
        </property>

#### 修改配置文件`hdfs-site.xml`

在`<property> </configuration>`中添加如下内容：

        <property>
            <name>dfs.namenode.secondary.http-address</name>
            <value>Master:50090</value>
        </property>
        <property>
            <name>dfs.namenode.name.dir</name>
            <value>file: /usr/local/hadoop/tmp/dfs/name</value>
            <description>Determines where on the local filesystem the DFS name node should store the name table.If this is a comma-delimited list of directories,then name table is replicated in all of the directories,for redundancy.</description>
            <final>true</final>
        </property>
        <property>
            <name>dfs.datanode.data.dir</name>
            <value>file: /usr/local/hadoop/tmp/dfs/data</value>
            <description>Determines where on the local filesystem an DFS data node should store its blocks.If this is a comma-delimited list of directories,then data will be stored in all named directories,typically on different devices.Directories that do not exist are ignored.
            </description>
            <final>true</final>
        </property>
        <property>
            <name>dfs.replication</name>
            <value>1</value>
        </property>
        <property>
            <name>dfs.permission</name>
            <value>false</value>
        </property>

#### 创建文件`mapred-site.xml`

这个文件本来不存在，但是文件夹中有一个`mapred-site.xml.template`，我们首先需要从模板
中复制一份，输入命令：

        $ cp mapred-site.xml.template mapred-site.xml

然后编辑`mapred-site.xml` ,在

    <configuration> </configuration>

之间添加如下内容：

        <property>
            <name>mapreduce.framework.name</name>
            <value>yarn</value>
        </property>
        <property>
            <name>mapreduce.jobhistory.address</name>
            <value>master:10020</value>
        </property>
        <property>
            <name>mapreduce.jobhistory.webapp.address</name>
            <value>master:19888</value>
        </property>
        <property>
            <name>mapreduce.jobhistory.intermediate-done-dir</name>
            <value>/mr-history/tmp</value>
        </property>
        <property>
            <name>mapreduce.jobhistory.done-dir</name>
            <value>/mr-history/done</value>
        </property>

#### 修改配置文件`yarn-site.xml`

在`<configuration> </configuration>`之间添加如下内容：

        <property>
            <name>yarn.resourcemanager.address</name>
            <value>master:8083</value>
        </property>
        <property>
            <name>yarn.resourcemanager.scheduler.address</name>
            <value>master:8081</value>
        </property>
        <property>
            <name>yarn.resourcemanager.resource-tracker.address</name>
            <value>master:8082</value>
        </property>
        <property>
            <name>yarn.nodemanager.aux-services</name>
            <value>mapreduce_shuffle</value>
        </property>
        <property>
            <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
            <value>org.apache.hadoop.mapred.ShuffleHandler</value>
        </property>
        <property>
            <description>The address of the RM web application.</description>
            <name>yarn.resourcemanager.webapp.address</name>
            <value>master:18088</value>
        </property>

这样Hadoop 的文件配置就结束了，配置好后，将 master 上的 Hadoop
文件复制到各个节点上。如果在
集群上之前跑过伪分布式，需要在切换到集群模式前删除之前的临时文件，这里需要删除之前所有节点
上的`namenode.name.dir`和`datanode.data.dir`，可以参考`hdfs-site.xml`
中的`dfs.namenode.name.dir`和`dfs.namenode.data.dir`的路径设置。具体的操作：

        $ rm -r ./hadoop/tmp # 删除 Hadoop 临时文件,如果有的话
        $ sudo tar -zcf  hadoop.tar.gz  hadoop # 在/usr/local 下执行
        $ scp -r hadoop.tar.gz hadoop@dmc001:/home/hadoop
        $ scp -r hadoop.tar.gz hadoop@dmc002:/home/hadoop
        $ scp -r hadoop.tar.gz hadoop@dmc003:/home/hadoop
        $ scp -r hadoop.tar.gz hadoop@dmc004:/home/hadoop
        $ scp -r hadoop.tar.gz hadoop@dmc005:/home/hadoop

这样将打包文件复制到五个节点上，在五个节点上分别执行如下操作，为Hadoop
用户赋予Hadoop 文件 夹的执行权限

        $ sudo tar -zxf ~/hadoop.tar.gz -C /usr/local
        $ sudo chown -R hadoop:hadoop /usr/local/hadoop

#### 设置Hadoop 的环境变量

在主节点和子节点的环境配置文件中增加Hadoop 的环境变量：

        $　sudo vim ~/.bashrc

增加如下内容：

        #HADOOP VARIABLES START
        export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
        export HADOOP_INSTALL=/usr/local/hadoop
        export PATH=$PATH:$HADOOP_INSTALL/bin
        export PATH=$PATH:$HADOOP_INSTALL/sbin
        export HADOOP_MAPRED_HOME=$HADOOP_INSTALL
        export HADOOP_COMMON_HOME=$HADOOP_INSTALL
        export HADOOP_HDFS_HOME=$HADOOP_INSTALL
        export YARN_HOME=$HADOOP_INSTALL
        export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native
        export HADOOP_OPTS="-Djava.library.path=$HADOOP_INSTALL/lib"
        #HADOOP VARIABLES END

然后执行

        $ source ~/.bashrc

使环境变量生效

### 调试及运行

然后在master 节点上，进入Hadoop 目录启动Hadoop,

        $ cd /usr/local/hadoop/
        $ bin/hdfs namenode -format
        $ sbin/start-dfs.sh          #启动hdfs
        $ sbin/start-yarn.sh         ##启动yarn

首次运行需要执行初始化，后面不再需要。这样就可以通过命令`jps`查看各个节点所启动的进
程。另外也可以在master 节点上通过以下命令查看DataNode是否正常启动。

        $ bin/hdfs dfsadmin -report

关闭Hadoop集群也是在master节点上执行,输入：

        $ sbin/stop-dfs.sh
        $ sbin/stop-yarn.sh

或是直接输入：

        $ sbin/stop-all.sh

在运行
时会有一个小提醒：`WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable`
我们可以通过选取之间未进行任何安装配置的文件解压后得到lib/native
文件夹，利用下面的命令来解决(同时在主节点和子节点操作)：

        $ sudo cp -r native /usr/local/hadoop/lib/

并编辑`hadoop-env.sh`文件

        $ sudo vim /usr/local/hadoop/etc/hadoop/hadoop-env.sh

在其中输入：

        export HADOOP_OPTS="-Djava.library.path=$HADOOP_PREFIX/lib:$HADOOP_PREFIX/lib/native"

保存退出后，就不会出现上面的警告了。
