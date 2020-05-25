---
bibliography:
- 'ref.bib'
---

基于Hadoop的分布式算法和模型实现
================================

R中实现Hadoop分布式计算
-----------------------

这一节，我们主要介绍R与Hadoop集成进行分布式计算。在R环境中编写Hadoop
MapReduce程序主要有三 种方式：

-   第一种，`Rhipe`包

-   第二种，`RHadoop`包

-   第三种，`HadoopStreaming`包

### `Rhipe`包

`Rhipe`包的全称为：R and Hadoop Integrated Programming
Environment，是R与Hadoop集成编程环境，此
包是由Mozilla公司的数据分析员Saptarshi
Guha和她的团队根据她在普渡大学读博士期间的毕业论文开
发出来的。`Rhipe`包使用D&R（Divide 和
Recombine）方式去处理大规模复杂数据，
它的作用就是使得用户在仅会使用R的情况下，依然可以通过R的控制台使用Hadoop的MapReduce等功能，
从而分析大规模复杂数据。用户通过R语言就可以灵活、高效地执
行Map和Reduce的相关命令。

#### `Rhipe`包安装

在安装`Rhipe`包之前，我们需要一个Linux环境并安装或者配置以下的包或环境：

-   Java 1.6以上版本

-   最新的Apache Ant

-   最新的Apache Maven

-   最新的 R

-   R的rJava，testthat和roxygen2包

-   Google protocol buffers (Hadoop
    2使用v2.5版本，其他版本的Hadoop使用v2.4.1)

-   pkg-config

按照以上要求，安装步骤如下；

首先安装Java、Hadoop和R。使用如下命令行查看是否安装java和Hadoop并查看版本：

        $ java -version
        $ hadoop version

我们这里使用的是1.7版本的java运行环境和2.4版本的Hadoop。Hadoop的安装请参考附录A。

安装Apache Ant和Apache
Maven。ApacheAnt是一个将软件编译、测试、部署等步骤联系在一起加以自动
化的一个工具，大多用于Java环境中的软件开发。而Maven是基于项目对象模型(POM)，可以通过一小段
描述信息来自动化管理项目管理和构建的软件项目管理工具。我们可以从命令行直接安装这两个工具。

        $ sudo apt-get install ant
        $ sudo apt-get install maven

安装以后，查看是否安装成功：

        $ ant –version
        $ mvn -v

安装协议缓冲组件google protocol buffer。Protocol
buffer是Google的一种数据交换格式，是一种轻
便高效的结构化数据存储格式，可以用于结构化数据串行化，或者说序列化。它可用于通讯协议、数据
存储等领域的语言无关、平台无关、可扩展的序列化结构数据格式。目前提供了
C++、Java、Python 三 种语言的
API。`Rhipe`需要依赖rJava包使得R可以与java进行交互，进而可以使
用Hadoop。而rJava包依赖于protocol buffer。github上protocol
buffer已经跟新到3.0.0版本，但是
由于我们的Hadoop是2.4版本的，所以，我们需要安装2.5版本的protocol buffer.
Protocol buffer的 安装比较简单，可以使用以下的脚本：

        $ wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
        $ tar -xzf protobuf-2.5.0.tar.gz

进入protobuf-3.0.0-alpha-3文件夹并安装protocol buffer：

        $ cd protobuf-2.5.0
        $ ./configure
        $ make
        $ sudo make install

配置环境变量。需要在Hadoop安装用户的用户目录下的`.bashrc`隐藏文件中配
置`PKG_CONFIG_PATH`和`LD_LIBRARY_PATH`两个变量，其
中`PKG_CONFIG_PATH`配置好后，系统安装库的时候就可以检索`PKG_CONFIG`脚
本。`LD_LIBRARY_PATH`则是用于加载共享库。可以在终端执行以下语句：

        $ export PKG_CONFIG_PATH=/usr/local/lib
        $ export LD_LIBRARY_PATH=/usr/local/lib

配置环境变量也可以使用R控制台执行或者编辑 /.Renviron文件：

        Sys.setenv(HADOOP_HOME="/usr/local/hadoop/")
        Sys.setenv(HADOOP_BIN="/usr/local/hadoop/bin")
        Sys.setenv(HADOOP_CONF_DIR="/usr/local/hadoop/conf")

最后查看protoc版本，是否安装成功：

        $ protoc --version

安装rJava包，testthat包，和roxygen2包。进入R控制台，在R控制台中输入如下命令：

        R> install.packages(c(“rJava”, ”testthat”, ”roxygen2”)

安装`Rhipe`。在完成了一下配置之后，我们可以安装`Rhipe`包了。

        R> system("wget http://ml.stat.purdue.edu/\texttt{Rhipe}bin/\texttt{Rhipe}_0.66.1.tar.gz")
        R> install.packages("\texttt{Rhipe}_0.66.1.tar.gz", repos=NULL, type="source")

#### `Rhipe`包的使用

`Rhipe`里面主要用的函数主要有以下几个：

-   `rhinit`：对RHive进行初始化

-   `rhget`：从HDFS中复制数据

-   `rhput`：把数据复制到HDFS中

-   `rhwrite`：把R中的数据写入HDFS中

-   `rhread`：把HDFS中数据读入得到R中

-   `rhgetkeys`：从Map文件中读取值

-   `rhex`：向Hadoop提交MapReduce的R对象

-   `rhmr`：创建一个MapReduce的对象

-   `rhcollect`：在Hadoop进行MapReduce时，向Hadoop MapReduce中写入数据

-   `rhstatus`：在Hadoop MapReduce运行时，更新工作状态。

下面我们给出一个计算K列数据均值和方差的例子：

首先是Mapper部分命令。Mapper部分在每个节点处计算数据的和以及平方和：

        map <- expression({
            ##K是需要计算的数据量
            K <- 10
            l <- length(map.values)
            ##把输入数据分割为行，并换为矩阵格式
            all.lines <- as.numeric(unlist(strsplit(unlist(map.values),"[[:space:]]+")))
            dim(all.lines) <- c(l, K)
            ##按列求和
            sums <- apply(all.lines, 2, sum)
            sqs <- apply(all.lines,2, function(r) sum(r^2))
            sapply(1:K, function(r) rhcollect(r, c(l,sums[r],sqs[r])))
        })

Reducer部分命令。将各个节点的数据汇总：

        reduce <- expression(
            pre = { totals <- c(0,0,0)},
            reduce = { totals <- totals +
                       apply(do.call('rbind', reduce.values),2,sum) },
            post = {rhcollect(reduce.key,totals) })

        mr <- list(mapred.reduce.tasks=K)
        ##使用rhmr开始调用Hadoop MapReduce
        y <- rhmr(map=map,reduce=reduce,combiner=TRUE,
                  inout=c("text","sequence"),ifolder="/tmp/somenumbers",
                  ofolder="/tmp/means",mapred=mr)
        w <- rhex(y,async=TRUE)

        ##获取Hadoop状态
        z <- rhstatus(w, mon.sec=5)
        results <- if(z$state=="SUCCEEDED") rhread("/tmp/means") else NULL
        if(!is.null(results)){
            results <- cbind(unlist(lapply(results,"[[",1)),
            ##展示输出结果
            do.call('rbind',lapply(results,"[[",2)))
            colnames(results) <- c("col.num","n","sum","ssq")
        }

### `RHadoop`包

`RHadoop`是RevolutionAnalytics工程的项目，开源实现代码在
GitHub社区可以找到。`RHadoop`包含三 个R包
(rmr，rhdfs，rhbase)，分别是对应Hadoop系统架构中的MapReduce， HDFS，
HBase 三个部 分。`RHadoop`的架构如下：

-   rhdfs包是一个在R控制台中提供HDFS可用性的R接口。使用rhdfs包可以很容易的像使用Hadoop
    MapReduce一样的从HDFS中读取数据和写入数据，一般来说，rhdfs包调用HDFS
    API去操作存储在HDFS上的数据。

-   rmr包是一个在R环境下提供Hadoop
    MapReduce功能的接口。因此，R程序员需要把程序逻辑分解
    成Map和Reduce两步，然后通过rmr提交给Job Tracker，接下来Job
    Tracker再把任务分配给各个节点，
    各自执行相应的任务。除了rmr包，rmr2包和plyrmr包也可以实现MapReduce接口功能（这两个包都依
    赖于rmr包）。

-   rhbase是一个通过Thrift服务器去操作分布式网络中的Hadoop
    HBase数据源的R接口。rhbase包使
    得R程序可以读写数据，修改HBase中存储的表。安装rhbase包需要依赖于Thrift。

在使用`RHadoop`时，并不是三个包都需要安装。如果我们存储的数据并不是在HBase中，我们就不需要安
装rhbase，只需安装rhdfs和rmr包即可。

#### `RHadoop`的安装

`RHadoop`的安装比较复杂，因为`RHadoop`中的几个包又都有较多依赖的包，所以配置起来较繁琐。下面我们逐步
介绍各个包的安装。

rmr包现在已经更新到第二个版本rmr2，但是CDH3和Apache1.0.2及以上的版本只能安
装rmr，从Apache2.2.0和HDP2以上的版本可以兼容rmr2。安装rmr包需要集群中每个节点都安装
了R-2.14以上的版本。每个节点都需要安装以下包：

        Rcpp
        RJSONIO (>= 0.8-2)
        digest
        functional
        reshape2
        stringr
        plyr
        caTools (>= 1.16)

以上是必须安装的包，还有几个包是建议安装的包：

        quickcheck,
        testthat (可从CRAN下载安装)
        rhdfs

这三个包是在测试时需要安装的包。如果使用rmr2包也需要在每个节点都安装，rmr2包不能从CRAN上
直接下载，它的安装需要从github上下载好安装包，通过R CMD
INSTALL命令安装。在安装
时，`HADOOP_CMD`和`HADOOP_STREAMING`环境变量一定要确保被正确设置。
`HADOOP_CMD`指向 Hadoop命令，而`HADOOP_STREAMING`环境变量指 向streaming
jar文件（大部分Hadoop版本都有一个名称类似于hadoop-streaming\*.jar的文件）。如
果rmr2不能找到可执行的hdfs的话，可以通过设置`HDFS_CMD`命令更改hdfs命令的路径。

rhdfs包依赖于rJava包，rJava包的安装在前面已经介绍过。使用rhdfs包连接HDFS依赖
于`HADOOP_CMD`环境变量，因此也需要设置。否则，rhdfs函数在使用初始化函数init()会报
错。

rhbase包的安装需要依赖于Thrift。rhbase包是使用Thrift0.8编写和测试的。

以下是安装`RHadoop`步骤：

-   安装依赖的R包。可以在R控制台执行如下的命令：

        R> install.packages( c('rJava','RJSONIO', 'itertools',
                            'digest','Rcpp','httr','functional',
                             'devtools', 'quickcheck','plyr','reshape2'))

-   设置环境变量

        ## 设置HADOOP_CMD环境变量
        R> Sys.setenv(HADOOP_CMD="/usr/local/hadoop/bin/hadoop")

        ## 设置 HADOOP_STREAMING环境变量
        R> Sys.setenv(HADOOP_STREAMING="/usr/local/hadoop/contrib/streaming/hadoop-streaming-1.0.3.jar")

    或者在Linux终端输入：

        $ export HADOOP_CMD=/usr/bin/hadoop
        $ export HADOOP_STREAMING=/usr/lib/hadoop/contrib/streaming/hadoop-streaming-<version>.jar

-   安装rmr2，rhdfs，rhbase包。首先从GitHub上下载`RHadoop`包，然后通过终端安装。

        #下载并安装rmr2
        $ wget https://github.com/RevolutionAnalytics/rmr2/releases/download/3.3.1
        /rmr2_3.3.1.tar.gz
        $ R CMD INSTALL rmr2_3.3.1.tar.gz

        #下载并安装rhdfs
        $ wget https://github.com/RevolutionAnalytics/rhdfs/blob/master/build/rhdfs_1.0.8.tar.gz?raw=true
        $ R CMD INSTALL rhdfs_1.0.8.tar.gz

        #下载并安装rhbase
        $ wget https://github.com/RevolutionAnalytics/rhbase/blob/master/build/rhbase_1.2.1.tar.gz?raw=true
        $ R CMD INSTALL rhbase_1.2.1.tar.gz

#### `RHadoop`的使用

首先，我们介绍一下如何在`RHadoop`下运行MapReduce。从概念上讲，MapReduce与lapply函数
和tapply函数的结合并没有很大的不同，他们处理的对象都是某个list中的元素。用MapReduce术语就是
对键值对的运算。让我们看一个简单的例子：

        R> small.ints = 1:1000
        R> sapply(small.ints, function(x) x^2)

这段程序的含义是计算1--1000的平方。如果用MapReduce写的话：

        R> small.ints = to.dfs(1:1000)
        R> mapreduce(
        R>     input = small.ints,
        R>     map = function(k, v) cbind(v, v^2))

其实这两段程序原理很相近，第一行都是输入数据，MapReduce就是先把数据输入到HDFS中。使用非常大
的数据集时，to.dfs函数并不现实，但是对于测试数据，to.dfs函数还是可用。to.dfs函数会产生一
个"big
data"类型的对象，这个对象并不会存储在内存中。通过一些命令，这个对象可以赋给其他变量，
传递到其他rmr函数，或者读回。第二行中使用了mapreduce函数。这个函数有两个参数，第一个参数
是要执行的数据对象，第二个参数是应用的函数，一般称为map函数（为了与reduce函数对应）。map函数
有一些要求：首先，map函数的输入变量为键值对；其次，其返回的函数也需要是一个键值对，这个键值
对是通过keyval函数生成的，数值可以是向量，列表（list），矩阵，数据框等任何的数据格式。在我们
的这个例子里面，我们并没有使用任何的键，只有值。返回的数据也是一个big
data对象。使 用from.dfs函数可以取回这个函数并显示。

下面我们再看另外一个例子：

        groups = rbinom(32, n = 50, prob = 0.4)
        groups = to.dfs(groups)
        from.dfs(
            mapreduce(
                input = groups,
                map = function(., v) keyval(v, 1),
                reduce = function(k, vv) keyval(k, length(vv))
            )
        )

这段程序是统计生成的32个参数为（50,
0.4）的二项分布随机数的每个随机数的个数。开始还是使
用to.dfs函数把数据读入HDFS中。在map函数中，输入的没有键，只有值，然后将值通过keyval函数转为
键，即将每个随机数值作为一个键，重复的数字形成相同的键。在reduce函数中自动对相同的键进行归集，将每个键的长度即该随机数的个数赋值为值，然后结果以键值对的形式保存，即完成了随机数个数的统计。

### R `HadoopStreaming`包

`HadoopStreaming`包的作者是David S. Rosenberg。这个包可以视作为一个简单
的MapReduce脚本框架。它可以在没有Hadoop的情况下处理streaming数据。甚至可以将这个R拓展包视作
一个Hadoop
MapReduce的简化版。这个包的安装非常简单，可以直接通过CRAN安装。在R控制台中执行以
下代码即可：

        R> install.packages("\texttt{HadoopStreaming}")

`HadoopStreaming`中只有五个函数，其中3个是读取数据的函数：

-   `hsTableReader`函数用来读取table形式的数据。

-   `hsKeyValReader`函数用来读取键值对形式的数 据。

-   `hsLineReader`函数用于按行读取数据，并将其转化为字符串，不对数据进行任何处理。

这三个函数中，只有`hsTableReader`会把数据分割为chunk，并且假定具有相同键值的行都在输入文件中
按序排好。这种情况常见于使用Hadoop
Streaming中的stdin读入数据时，因为Hadoop会保证传递
给Reduce的数据都已经通过键排序过。当我们使用命令行读取数据时，我们可以自己对键进行排序。

我们以`hsKeyValReader`为例，其他两个函数与这个函数的用法类似：

        #创建字符串键值对，\t，\n分别为tab和回车的转义符
        str <- "key1\tval1\nkey2\tval2\nkey3\tval3\n"

        #显示
        cat(str)
        #结果为：
        key1    val1
        key2    val2
        key3    val3

        #将数据转成textConnection类型对象
        con <- textConnection(str, open = "r")

        #打印结果
        printFn <- function(k,v) {
        cat('A chunk:\n')
        cat(paste(k,v,sep=': '),sep='\n')
        }
        hsKeyValReader(con,chunkSize=2,FUN=printFn)
        #结果如下
        A chunk:
        key1: val1
        key2: val2

除了以上读取数据的函数之外，`hsCmdLineArgs`函数提供了几条有用的命令行表达式，功能包括指定输入
输出文件，确定列分隔符，指定读取行数等。`hsCmdLineArgs`函数严重依赖
于getopt包。`hsCmdLineArgs`函数也帮助mapper和reducer的脚本转化为一个R脚本。`hsCmdLineArgs`函数
的使用方式是：

        R> hsCmdLineArgs(spec=c(),openConnections=TRUE,args=commandArgs(TRUE))

其中spec向量要求长度为6的倍数，指定一系列的命令行表达式，每一条指令都是由6个指令构成。spec参数与getopt包中的getopt函数的表达式相同，这六个指令包括：

-   长标志名

-   短标志名

-   参数类型声明：有三个值，0代表无参数，1代表必要参数，2代表可选参数。

-   数据类型：'logical', 'integer', 'double', 'complex',
    或者'character'其中之一。

-   用来说明功能的字符串

-   参数的默认值

例如如下一个字符串：

        R> spec=c('mapper', 'm',0, "logical","Runs the mapper.",F)

就是一个完整的mapper命令行表达式。

Mahout 与大数据机器学习
-----------------------

Mahout
是Apache旗下的开源项目，集成了大量的机器学习算法，是一个强大的数据挖掘工具。它包括被
称为Taste的分布式协同过滤的实现、分类、聚类等。Mahout最大的优点就是基于分布式系统的实现，把
很多以前运行于单机上的算法，转化为了并行模式，大大提高了算法的计算效率。Mathout的最早开发是
基于Hadoop架构的，在最新的版本里，Mahout已经可以独立于Hadoop运行或者运行于Spark之上。

Mahout的算法包括以下内容：

-   分类算法

        Logistic Regression                         逻辑回归
        Bayesian                                    贝叶斯
        SVM                                         支持向量机
        Perceptron                                  感知器算法
        Neural Network                              神经网络
        Random Forests                              随机森林
        Restricted Boltzmann Machines               有限波尔兹曼机

-   聚类算法

        Canopy Clustering                           Canopy聚类
        K-means Clustering                          K均值算法
        Fuzzy K-means                               模糊K均值
        Expectation Maximization                    EM聚类（期望最大化聚类）
        Mean Shift Clustering                       均值漂移聚类
        Hierarchical Clustering                     层次聚类
        Dirichlet Process Clustering                狄里克雷过程聚类
        Latent Dirichlet Allocation                 LDA聚类
        Spectral Clustering                         谱聚类

-   关联规则挖掘

        Parallel FP Growth Algorithm                并行FP Growth算法

-   回归

        Locally Weighted Linear Regression          局部加权线性回归

-   降维/维约简

        Singular Value Decomposition                奇异值分解
        Principal Components Analysis               主成分分析

-   进化算法

        Independent Component Analysis              独立成分分析

-   推荐/协同过滤

        Gaussian Discriminative Analysis            高斯判别分析
        Non-distributed recommenders
        Taste(UserCF, ItemCF, SlopeOne）
        Distributed Recommenders
        ItemCF

-   向量相似度计算

        RowSimilarityJob                            计算列间相似度
        VectorDistanceJob                           计算向量间距离

-   非Map-Reduce算法

        Hidden Markov Models                        隐马尔科夫模型

-   集合方法扩展

        Collections                                 扩展了Java的Collections类

利用Mahout进行数据挖掘
----------------------

为了说明Mahout的简单用法，我们以k-means算法为例来演示如何利用Mahout进行数据挖掘，其他的
Mahout的应用示例请参考[@owen2011mahout]。

#### 数据的获取

文本数据分析是一类特殊又重要的统计分析，对网页、文档的分析方法参
见@aggarwal2012mining、@russell2013mining、@manning1999foundations等文
献。在本文中，我们选择经典的 `Reuters21578`
文本语料。尝试对新闻内容进行文本聚类。使
用如下命令可以下载我们需要的数据文件：

        $ axel -n 20 http://kdd.ics.uci.edu/databases/reuters21578/reuters21578.tar.gz

然后将文件解压到/home/dmc/lrq/reuters-sgm路径下：

        $ tar -xzvf ./reuters21578.tar.gz ./reuters-sgm

解压缩之后，reuters-sgm下包含了若干\*.sgm文件，我们需要的文本就包含在这些文件中。

#### 抽取文件中的文本

我们需要的文本数据包含在\*.sgm文件中，不能直接使用，需要将这些文本提取出来。Mahout中提供了这
样的程序。我们可以使用如下命令：

        $ mahout org.apache.lucene.benchmark.utils.ExtractReuters \
        ./reuters-sgm\
        ./reuters-out

在当前路径下创建了一个新的文件夹reuters-out，其中保存了我们提取出来的文件。

#### 转换序列文件

HDFS是为处理数量少但是体量大的文件而设计的，如果文件数太多，会大大影响HDFS的处理效果。因
此，Mahout采用SequenceFile作为其基本的数据交换格式。

        $ mahout seqdirectory -i file://$(pwd)/reuters-out/ \
        -o file://$(pwd)/reuters-seq/
        -c UTF-8 -chunk 64 -xm sequential

经过以上命令的处理，我们在/home/dmc/lrq/reuters-seql路径下得到新的数据文件。

#### 向量表示

首先，我们将文件上传到HDFS中：

        $ hadoop dfs -put reuters-seq /user/dmc

Mahout中提供了程序可以将序列数据转换成空间向量：

        $ mahout seq2sparse -i /user/dmc/reuters-seq \
        -o /user/dmc/reuters-sparse \
        -ow --weight tfidf --maxDFPercent 85 --namedVector

其中：dictionary.file-0：词文本$\to$词id(int)的映射。词转化为id，这是常见做
法。frequency.file：词id$\to$文档集词频(cf)。wordcount(目录)：
词文本$\to$文档集词
频(cf)，这个应该是各种过滤处理之前的信息。df-count(目录)：
词id$\to$文档频 率(df)。tf-vectors、tfidf-vectors
(均为目录)：词向量，每篇文档一行，格式为词id:特
征值，其中特征值为tf或tfidf。采用了内置类型VectorWritable，需要用命令"mahout
vectordump -i \<path\>"查看。tokenized-documents：分词后的文档。

#### k-means聚类

数据处理好之后，我们来运行Mahout中的k-means算法：

        $ mahout kmeans -i /user/dmc/reuters-sparse/tfidf-vectors \
        -c /user/dmc/reuters-kmeans-clusters \
        -o /user/dmc/reuters-kmeans \
        -k 20 -dm \
        org.apache.mahout.common.distance.CosineDistanceMeasure \
        -x 200 -ow --clustering

聚类之后的结果就保存
在/user/dmc/reuters-kmean和/user/dmc/reuters-kmeans-clusters两个路径下。其
中，/user/dmc/reuters-kmeans-clusters中保存的是初始随机选择的中心
点，/user/dmc/reuters-kmean中保存的是聚类的结果。
