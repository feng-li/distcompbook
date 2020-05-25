Spark与分布式计算
=================

Spark简介
---------

### Spark的历史和发展

Spark是一种分布式计算框架，它使用了内存运算技术，具有支持迭代计算和低延迟等特点。
这些特点使得Spark的运算效率大大高于传统的分布式计算系统Hadoop。相对而言，MapReduce比较适合离线数据的处理，
但随着业务场景的发展，实时查询和迭代计算的需求逐渐增多，Spark则可以提供更好的支持。
同时Spark还具有高容错性和高可伸缩性，可以将Spark部署在大量的廉价的设备之上，形成大规模的集群。

Spark最初由加州大学伯克利分校的AMPLab实验室开发，目前正迅速被用户接受，并应用于企业生产中。它
于2010年正式开源，并且在2013年成为Apache的基金项目，
2014年它成为Apache基金的顶级开源项
目，整个过程只用了五年时间。如此短时间的巨大成功，不得不让人惊叹。

-   2009年：Spark诞生

-   2010年：正式成为开源项目

-   2013年：成为Apache基金项目

-   2014年2月：成为Apache顶级基金项目

-   2014年4月：大数据公司MapR加入Spark阵营，Apache
    Mahout放弃MapReduce，使用Spark作为 计算引擎。

-   2014年5月：Spark1.0.0发布

-   2014年7月：Hive on Spark项目启动

-   2016年7月：Spark2.0.0发布

-   2018年11月：Spark2.4.0发布

到目前为止，AMPLab和DATABRICKS负责着整个项目的开发和维护，同时，有很多的开源爱好者也积极地
加入到Spark的更新和维护之中。

### Spark的社区活动

Spark对于社区活动十分重视，拥有规范的组织，经常会定期或者不定期地举行相关讨论会议。Spark会
议可以分为两种，一种叫做Spark
Summit，拥有巨大的影响力，是全世界的Spark项目顶尖技术人员峰会。
目前为止，已经在2013年至2017年于旧金山连续召开了五届Summit峰会。2018年后，Spark
Summit升级为Spark+AI
summit，于3月1日如期在旧金山举行，更多峰会信息可参考Spark Summit官方
网站：`http://spark-summit.org/`。

2014年，在Spark Summit峰会参与者中，除了UC
Berkley和Databricks之外，还有许多最早尝试Spark进
行大规模数据分析的企业，包括云计算的领先者亚马逊公司、全球最大的流媒体音乐网站Spotify，著名大数据平台MapR，以及众多的大型企
业IBM、Intel、SAP等。

除了Spark
Summit会议之外，Spark社区还会不定期地召开小规模的Meetup会议，这种会议有可能在世界
各地举行。在中国，
Meetup会议已经举行了多次，参会人员包括来自Intel中国研究院、TalkingData、淘宝、Databricks、微软亚洲研究院的工程师们。下图为Meetup会议在全球的分布状况：

![Spark
Meetup会议全球分布图[]{label="fig:SPark-Meetups"}](ch6/Spark-Meetups){#fig:SPark-Meetups
width="47%"}

### Spark和Hadoop的比较

首先，我们需要了解一下spark与Hadoop的关系。准确地说，Spark是一个分布式计算框架，而Hadoo则更像是
为分布式计算提供服务的基础设施，Hadoop中不仅包含一个计算框架MapReduce，同时也包含分布式的文
件系统HDFS，以及其他的Hadoop项目，比如Hbase、Hive等。因此，Spark可以看作是MapReduce的一种可替代方案，
它并不是和Hadoop同一级别的项目。同时，Spark还兼容HDFS、Hive的分布式存储层，可以将其融入到Hadoop的
生态环境中。因此，如果你有一个安装好的Hadoop集群，那么就可以在这个基础上直接部署Spark了。更多
关于Spark的介绍请参考@karau2015learning。

说到这里，我们可以发现，Spark与Hadoop的比较这种说法是不合适的，真正具有可比性的
是Hadoop中的MapReduce计算框架。那么Spark与MapReduce相比到底具有哪些优势呢？

-   中间输出结果上的优势

    对于MapReduce计算框架，中间计算结果会输出在计算机的硬盘上，当需要的时候再进行调用。由于
    需要考虑任务管道承接的问题，当一些查询翻译到MapReduce任务时，往往会产生多个Stage，而这些
    串联的Stage又依赖于底层文件系统（如HDFS）来存储每一个Stage的输出结果，产生了较高的延迟。
    Spark将执行模型抽象为通用的有向无环图执行计划（DAG），这可以将多Stage的任务串联或者并行执
    行，而无须将Stage中间结果输出到HDFS中。类似的引擎包括Dryad、Tez。

-   数据格式和内存布局

    由于MapReduce Schema on
    Read处理方式会引起较大的处理开销，Spark抽象出分布式内存存储结构弹
    性分布式数据集RDD，进行数据的存储。RDD能支持粗粒度写操作，但对于读取操作，RDD可以精确到每
    条记录，这使得RDD可以用来作为分布式索引。Spark的特性是能够控制数据在不同节点上的分区，用
    户可以自定义分区策略，如Hash分区等。Shark和Spark
    SQL在Spark的基础之上实现了列存储和列存储 压缩。

-   执行策略

    MapReduce在数据Shuffle之前花费了大量的时间来排序，Spark则可减轻上述问题带来的开销。因
    为Spark任务在Shuffle中不是所有情景都需要排序，所以支持基于Hash的分布式聚合，调度中采用更
    为通用的任务执行计划图（DAG），每一轮次的输出结果在内存缓存。

-   任务调度的开销

    传统的MapReduce系统，如Hadoop，是为了运行长达数小时的批量作业而设计的，在某些极端情况下，
    提交一个任务的延迟非常高。Spark采用了事件驱动的类库AKKA来启动任务，通过线程池复用线程来避
    免进程或线程启动和切换开销。

### Spark的特点

-   拥有高效的数据流水线

    除了传统的MapReduce操作之外，Spark还可以支持SQL语句查询、机器学习图模型算
    法[@nicolas2014scala]等等，用户可以在一个工作的流程中将这些功能完美的组合起来。

-   强大的快速处理功能

    Spark是一款轻量级的软件系统，第一代spark核心程序只有4万行代码。Spark为处理大数据而生，最
    重要的一个特点就是将结果缓存在内存中，从而达到提高计算效率，减少计算时间的目的。

-   可用性

    Spark提供了丰富的Scala, Java，Python
    API及交互式Shell来提高软件的可用性。使用者可以
    在Spark系统中像书写单机程序一样来书写分布式计算程序，轻松的利用spark系统搭建的分布式计算
    平台来处理海量的数据。

-   容错性

    Spark系统通过checkpoint实现系统的容错功能。checkpoint主要有两种方式，一种是checkpoint
    data，一种是logging the
    updates。用户可以自主决定采用哪种方式来实现容错功能。

-   与HDFS、HBase、hive等兼容

    Spark除了可以运行在YARN等分布式集群系统之外，还可以读取现存的任何的Hadoop数据。它可以在任
    何Hadoop数据源上运行，如Hive、HBase等等。

### Spark生态：BDAS

从Spark产生到现在，已经发展成为包括许多子项目的分布式计算平台。伯克利实验室将整个Spark的生
态系统称为伯克利数据分析栈，也就是常说的BDAS。其中，Spark是整个系统的核心。与此同时，BDAS还包
含了结构化数据查询引擎Spark
SQL和Shark，提供机器学习功能的MLlib，流计算系统Spark
Streaming，并行图计算系统GraphX等等。这些项目为Spark系统提供了更加丰富的计算范式，使
得Spark的功能更加强大。

BDAS系统包含如下内容：

-   Spark

    Spark是一个快速通用的分布式数据处理系统，不仅实现了Hadoop系统的MapReduce算子map
    函数
    和reduce函数，还提供了其他的算子，例如filter、join、groupByKey等。弹性分布式数据集（RDD）
    处理分布式数据的核心，实现了重要的应用任务调度、RPC、序列化和压缩功能，并为上层组件提供
    了API。Spark底层采用Scala语言书写而成，提供给使用者与Scala类似的程序接口。对于Scala语言
    的使用，请参考@odersky2008programming和@ryza2015advanced。

-   Shark

    Shark是spark生态系统中的数据仓库，构建在Hive的基础之上。目前shark已经终止了开发。

-   Spark SQL

    Spark SQL为用户提供了spark系统中的数据查询功能。Spark
    SQL使用Catalyst做为查询解析和优化器， 并且Spark
    SQL在底层使用Spark作为执行引擎来实现SQL查询操作，性能普遍比Hive快2-10倍。同时，用
    户可以在Spark上直接编写SQL代码，这相当于为Spark提供了一套强大的SQL算子。同时Spark
    SQL还不断
    的兼容不同的Hadoop项目（如HDFS、Hive等），为它的发展提供了广阔空间。

-   Spark Streaming

    Spark
    Streaming是一种构建在Spark上的实时的计算框架，它为Spark提供了处理大规模流数据的能
    力。Spark
    Streaming的优势在于：能运行在超过100以上的结点上，并达到秒级延迟；使用Spark作为
    执行引擎，具有比较高的效率和容错性；可以集成Spark的批处理和交互查询功能，为实现复杂的算法
    提供简单的接口。

-   GraphX

    GraphX是基于BSP模型的图计算项目，在Spark上封装了类似Pregel的接口，进行大规模的同步全
    局的图计算，当用户进行多轮迭代的时候，基于Spark内存计算的GraphX优势更为明显。

Spark工作原理介绍
-----------------

### Spark架构

Spark的架构采用了经典的Master-Slave通用基础框架。其中Master是集群中的含有Master进程的节点，
而Slave是集群中含有Worker进程的节点。Master是整个集群的控制器，负责了整个集群的运
行；Worker相当于是集群的计算节点，接收来自主节点的命令同时进行状态汇报；Executor负责执行具
体的任务；Client是用户的客户端，作用是提交应用，而Driver则是负责控制应用的执行。

Spark分布式集群安装好之后，需要在主节点和子节点上分别启动Master进程以及Worker进程，从而控制
整个集群的运行。在一个Spark任务执行的过程中，
Driver程序是任务逻辑执行的起点，负责了整个作
业的调度，而Worker则是用来管理计算节点和创建Executor然后处理任务。在任务的执行阶
段，Driver会将任务和任务所依赖的file和jar序列化之后传递给相应的Worker节点，同时Executor对相
应的数据分区的任务进行处理。

### Spark组件介绍

下面介绍一下Spark架构中的基本组成部分。

-   Client：客户端进程，负责提交作业信息到Master。

-   Master：负责接收Client提交的作业，管理Worker，并命令Worker启动Driver和Executor。

-   ClusterManager：在Standalone模式中的Master（主节点），控制着整个集群，监控Worker的工
    作情况。

-   Worker：子节点，负责控制具体的计算节点，启动Driver和Executor完成任务。在YARN模式中称
    为NodeManager。

-   Driver：一个Spark作业的主进程，运行Application的main()函数并创建SparkContext，负责作业的解析
    、生成Stage并调度Task到Executor上。

-   Executor：执行器，在worker
    node上执行任务的组件、用于启动线程池运行任务。每
    个Application拥有独立的一组Executors。

-   SparkContext：整个应用的上下文，控制应用的生命周期，Spark应用程序的执行过程中起着主导作用，它负责
    与程序和spark集群进行交互，包括申请集群资源、创建RDD等。

-   RDD：Spark的基本计算单元，一组RDD可形成执行的有向无环图RDD Graph。

-   DAG
    Scheduler：根据应用（Application）构建基于Stage的DAG，实现将Spark作业分解成一到多个Stage，
    每个Stage根据RDD的Partition个数决定Task的个数，并提交Stage给TaskScheduler。

-   TaskScheduler：将任务（Task）分发给Executor执行。

-   SparkEnv：线程级别的上下文，存储运行时的重要组件的引用。

-   SparkEnv内创建并包含如下一些重要组件的引用。

-   MapOutPutTracker：负责Shuffle元信息的存储。

-   BroadcastManager：负责广播变量的控制与元信息的存储。

-   BlockManager：负责存储管理、创建和查找块。

-   MetricsSystem：监控运行时性能指标信息。

-   SparkConf：负责存储配置信息。

SparkContext是Spark的主要入口点，如果把Spark集群当作服务端那Spark
Driver就是客户端，SparkContext则是客户端的核心，
创建SparkContext的语句如下：

    val conf = new SparkConf().setMaster("master").setAppName("appName")
    val sc = new SparkContext(conf)

SparkContext的初始化需要一个SparkConf对象，SparkConf包含了Spark集群配置的各种参数。其中setMaster主要是设定连接主节点，
如果参数是\"local\"，则在本地用单线程运行spark，如果是
local\[4\]，则在本地用4核运行。setAppName则是给出指定的Spark应用一个名称。

### Spark工作流程

用户在Client中提交了任务之后，Master会找到一个Worker然后启动Driver，Driver会根据要执行的任
务向Master申请资源，之后将任务转化为RDD
Graph，再由DAGScheduler（功能：将Spark作业分解成一
到多个Stage，每个Stage根据RDD的Partition个数决定Task的个数，然后生成相应的Task
set放到TaskScheduler中）将RDD Graph转化为Stage的有向无环图提交
给TaskScheduler，由TaskScheduler提交任务给Executor执行。在任务执行的过程中，其他组件协同工
作，确保整个应用顺利执行。

### Spark核心：RDD

在Spark集群中，有一个非常重要的核心：分布式数据架构，也就是弹性分布式数据集（resilient
distributed
dataset，RDD）。RDD可以在集群的多台机器上进行数据分区。最重要的一点，它可以通过
对不同台机器上不同数据分区的控制，减少集群机器之间数据重排（data
shuffling）的数量。Spark提
供了"partitionBy"运算符，能够通过集群中多台机器之间对原始RDD进行数据再分配来创建一个新
的RDD。RDD是Spark的核心数据结构，通过RDD的依赖关系形成Spark的调度顺序。通过对RDD的操作形成
整个Spark程序。对于详细的Spark操作，请参考@yadav2015spark。

对于MapReduce来说，HDFS上存储的数据就是它的输入。而RDD则可以看作是Spark的输入，作为Spark输入的
RDD有以下五大特征：
1）分区性（partition）：RDD数据可以被分为几个分区（子集），切分后的数据能够进行并行计算，是数据集的原子组成部分。
2）计算函数（compute）：RDD的每个分区上面都会有函数，其作用是实现RDD之间分区的转换。
3）依赖性（dependency）：RDD通过特定的转化操作，可以得到新的RDD，新的RDD和旧的RDD之间存在依赖关系，这种依赖关
系保证了部分数据丢失时可以特定的转化操作重新生成。
4）优先位置（perferred
locations）：这是一个可选属性，在有些子RDD中并没有实现。RDD计算时会存取每个Partition
的优先位置（preferred
location）。按照"移动数据不如移动计算"的理念，Spark在进行任务调度时，会尽可能地将计
算任务分配到其所要处理数据块的存储位置。
5）分区策略：这也是一个可选属性，描述数据分区模式和数据存放的位置。如果RDD里面存的数据是key-value形式，则可以传递
一个自定义的Partitioner进行重新分区，例如这里自定义的Partitioner是基于key进行分区，那则会将不同RDD里面的相
同key的数据放到同一个partition里面。类似于MapReduce中的Partitioner接口。

#### RDD的两种创建方式

-   从Hadoop文件系统（或与Hadoop兼容的其他持久化存储系统，如Hive、Cassandra、Hbase）输入
    （如HDFS）创建。

-   从父RDD转换得到新的RDD。

#### RDD的两种操作算子

对于RDD可以有两种计算操作算子：Transformation（转换）与Action（执行），Transformation指定了RDD之间
的依赖关系，Action则指定了RDD操作最后的输出形式。

-   Transformation（变换）

    Transformation操作是延迟计算的，也就是说从一个RDD转换生成另一个RDD的转换操作不是马上执行，
    需要等到有Action操作时，才真正触发运算。

-   Action（行动）

    Action算子会触发Spark提交应用（Application），并将数据输出到Spark系统。

常见的RDD转换（Transformation）和执行（Actions）操作如下：

  Transformation            说明
  ------------------------- --------------------------------------------------------------------------------------------------------------
  map(func)                 参数是函数func，函数应用于RDD每一个元素，返回值是新的RDD
  filter(func)              参数是函数func，选取数据集中使得函数func返回值为True的元素，返回值是新的RDD
  flatMap(func)             参数是函数func，函数应用于RDD每一个元素，将元素数据进行拆分，每个元素可以被映射到多个输出项，返回值是新的RDD
  distinct()                没有参数，将RDD里的元素进行去重操作
  union()                   参数是RDD，返回包含两个RDD所有元素的新RDD
  intersection()            参数是RDD，返回两个RDD的共同元素
  cartesian()               参数是RDD，求两个RDD的笛卡儿积
  coalesce(numPartitions)   将RDD分区的数目合并为numPartitons个

  Action                       说明
  ---------------------------- -----------------------------------------------------------------------
  collect()                    以数组的形式，返回RDD所有元素
  count()                      返回RDD里元素的个数
  countByValue()               各元素在RDD中出现次数
  reduce(func)                 通过函数func聚集数据集中的所有元素，并行整合所有RDD数据，例如求和操作
  aggregate(0)(seqOp,combop)   和reduce功能一样，但是返回的RDD数据类型和原RDD不一样
  foreach(func)                对RDD每个元素都是使用特定函数func
  saveAsTextFile(path)         将数据集的元素作为一个文本文件保存至文件系统的给定目录path中
  saveAsSequenceFile(path)     将数据集的元素以sequence的形式保存至文件系统的给定目录path中

#### RDD的重要内部属性

-   分区列表。

-   计算每个分片的函数。

-   对父RDD的依赖列表。

-   对Key-Value对数据类型RDD的分区 器，控制分区策略和分区数。

-   每个数据分区的地址列表（如HDFS上的数据块的地址）

在Spark的执行过程中，RDD经历一个个的Transfomation算子之后，最后通过Action算子进行触发操作。
逻辑上每经历一次变换，就会将RDD转换为一个新的RDD，RDD之间通过Lineage产生依赖关系，这个关系
在容错中有很重要的作用。变换的输入和输出都是RDD。RDD会被划分成很多的分区分布到集群的多个节
点中。分区是个逻辑概念，变换前后的新旧分区在物理上可能是同一块内存存储。这是很重要的优化，
以防止函数式数据不变性（immutable）导致的内存需求无限扩张。有些RDD是计算的中间结果，其分区
并不一定有相应的内存或磁盘数据与之对应，如果要迭代使用数据，可以调cache()函数缓存数据。

#### RDD的工作特点

在物理上，RDD对象实质上是一个元数据结构，存储着Block、Node等的映射关系，以及其他的元数据信
息。一个RDD就是一组分区，在物理数据存储上，RDD的每个分区对应的就是一个Block，Block可以存储
在内存，当内存不够时可以存储到磁盘上。

每个Block中存储着RDD所有数据项的一个子集，暴露给用户的可以是一个Block的迭代器（例如，用户可
以通过mapPartitions获得分区迭代器进行操作），也可以就是一个数据项（例如，通过map函数对每个
数据项并行计算）。

### Spark算子的分类及作用

算子是RDD中定义的函数，可以对RDD中的数据进行转换和操作，Spark的所有功能都是通过具体的算子
来实现的。

-   输入：在Spark程序运行中，数据从外部数据空间（如分布式存
    储：textFile读取HDFS等，parallelize方法输入Scala集合或数据）输入Spark，数据进入Spark运行
    时数据空间，转化为Spark中的数据块，通过BlockManager进行管理。

-   运行：在Spark数据输入形成RDD后便可以通过变换算子，如fliter等，对数据进行操作并将RDD转
    化为新的RDD，通过Action算子，触发Spark提交作业。如果数据需要复用，可以通过Cache算子，将数
    据缓存到内存。

-   输出：程序运行结束数据会输出Spark运行时间，存储到分布式存储中（如saveAsTextFile输出
    到HDFS），或Scala数据或集合中（collect输出到Scala集合，count返回Scala
    int型数据）。

Spark的核心数据模型是RDD，但RDD是个抽象类，具体由各子类实现，如MappedRDD、ShuffledRDD等子
类。Spark将常用的大数据操作都转化成为RDD的子类。

Spark算子大致可以分为三大类算子。

-   Value数据类型的Transformation算子，这种变换并不触发提交作业，针对处理的数据项是Value型的
    数据。

-   Key-Value数据类型的Transfromation算子，这种变换并不触发提交作业，针对处理的数据项
    是Key-Value型的数据对。

-   Action算子，这类算子会触发SparkContext提交Application。

Pyspark命令介绍
---------------

### Pyspark简介

Spark客户端支持交互方模式以方便应用调试，通过调用Pyspark可以进入交互环境。

\$ pyspark

若调用Pyspark时传入Python脚本路径，则Pyspark直接调用spark-submit脚本向Spark集群提交任务；若调用Pyspark时未带任何参数，则会调用Pyspark解释器进入交互模式。

当进入交互模式并向Spark集群提交任务后，本地会在执行Pyspark脚本时先启动一个被称为driver
program的Python进程并创建SparkContext对象，而后者会通过Py4J启动一个JVM进程并创建JavaSparkContext对象，该JVM进程负责与集群的worker节点传输代码或数据。

Pyspark建立在Spark Java
API之上，数据按照Python的语法行为被处理，执行结果由JVM负责cache与shuffle。用户提交的Python脚本中实现的RDD
Transformation操作会在本地转换为Java的PythonRDD对象，后者由本地的JVM发往Spark集群节点。在远程的worker节点上，PythonRDD对象所在的JVM进程会调起Python子进程并通过pipe进行进程间通信（如向Python子进程发送用户提交的Python脚本或待处理的数据）。Pyspark数据流交互结构如图[1.2](#fig:pyspark){reference-type="ref"
reference="fig:pyspark"}所示。

![Pyspark数据流交互结构[]{label="fig:pyspark"}](ch6/pyspark){#fig:pyspark
width="40%"}

### 创建SparkContext

SparkContext实例可以实现与一个Spark集群的链接，是与Spark进行交互的入口。通过SparkContext我
们可以提交提交编写好的spark应用。运行下面的代码可以创建一个SparkContext实例：

        Pyspark> from pyspark import sparkcontext
        Pyspark> sc=sparkcontext(master , appName, sparkHome="sparkhome", pyFiles="pla.zip")

其中，master可以是"local"，也可以是指向一个Spark集群的URL，appName是你所要提交的应
用的名称，sparkHome是Spark的根目录路径，pyFile指定你所依赖的文件。

### 数据的加载和保存

RDD是spark中数据表示的主要单元，使数据操作的执行变得简单易学。Spark可以通过很多途径将数据加
载到RDD中。直接将Scala数据集转化为RDD是一种创建RDD最简单的方式。sparkContext提供一
个parallelize函数，这个函数可以以Scala集合为参数，然后将它转化为一个RDD。

        Pyspark> rdd = sc.parallelize([1,2,3])

加载文本文件中的数据是另外一种比较简单的加载外部数据的方式，需要数据在每个节点上都有备份，
如果是在本地模式下不用考虑这个问题，但如果是在分布式模式下，可以使用spark的addFile函数拷贝
数据到集群的每个节点上。

        Pyspark> from pyspark.files import SparkFiles
        Pyspark> sc.addFile(“spam.data”)
        Pyspark> sc.textFile(SparkFiles.get(“spam.data”))

使用上述命令得到的RDD是一个字符串数据集，文本文件中的每一行是RDD中的一个独立的元素。另外，
如果是csv文件，我们可以使用一个标准的CSV库来进行解析。通过spark运算得到的结果我们要保存下来。
当我们通过SparkContext定义一个RDD实例的时候，相应的保存数据的方法也被定义到了相应的RDD实例中。

        Pyspark> rddOfStrings.saveAsTextFile(“out.txt”)

### 使用Python操作RDD

最经典的操作方式是大家比较熟悉的mapreduce。map函数对输入RDD中的一个元素调用一个函数，该函数
输出一个新的元素。例如，我们可以给所有的元素加上一，生成一个新的RDD。实现的代码
是`rdd.map(lambda x: x+1)`。这个匿名函数会作用在RDD的每一个元素上。map函数不会改变RDD的值，
而是生成一个新的RDD。reduce函数对所有的元素调用同一个函数，可以把所有的数据合并在一起，并返
回最终的调查结果。实现的代码是`rdd.reduce(lambda x,y : x+y)`。除了reduce之外，还有一个对应
的reduceByKey函数。专门针对键值对类型的数据，生成新的RDD。以下是Python中常用的RDD函数。

#### 标准的RDD函数

-   `flatMap (f, preservesPartitioning=False)`

    以一个函数作为参数，这个函数作用于每一个输入类型为T的元素，返回一个类型为U的iterator对
    象。flatMap可以返回一个元素类型为U的扁平化RDD。mapPartitions (f,
    preservesPartitioning=False)以一个函数作为参数，这个函数输入类型为T的iterrator，输出的是
    一个类型为U的iterrator，最终结果是一个类型为U的RDD。

-   `filter(f)`

    以一个函数为参数，返回的RDD中包含所有被函数结算后结果为true的元素。

-   `distinct()`

    返回去掉了重复元素的RDD，例如输入的是\[1, 2, 3, 1\]，输出的是\[1, 2,
    3\]

-   `union(other)`

    返回两个RDD的并集

-   `cartesian(other)`

    返回两个RDD的笛卡尔积

-   `groupBy(f, numPartitions=None)`

    返回值是经过参数函数的输出集合之后得到的元素组成的RDD

-   `pipe(command, env=)`

    让RDD中的每一个元素都流过一个外部命令定义的管道，输出一个RDD

-   `foreach(f)`

    将操作元素作用在每个元素上

-   `reduce(f)`

    用给定的函数合并所有元素

-   `fold(zeroValue, op)`

    用提供的操作对之进行合并，首先合并每个分区，然后合并每个分区的结果

-   `countByValue()`

    返回一个字典的映射，记录每个值以及它在RDD中出现的次数

-   `take(num)`

    返回含有num个元素的列表，如果num的值很大，这个函数会变得很慢，如果要读区整个RDD，使用collect函数更合适

-   `partitionBy(numPartitions, partitionFunc=hash)`

    用新的分区函数来分区RDD。partitionFunc参数只需要简单的把输入映射到一个整数空间上，partitionBy将整数与numPartition取模即可

#### pairRDD函数

以下的函数都是针对键值对开发的函数。

-   `collectAsMap()`

    返回一个有RDD所有键值对组成的字典

-   `reduceByKey(func, numPartitions=None)`

    用提供的函数参数func把每个Key下的所有value合并在一起，生成一个RDD

-   `countByKey()`

    返回一个字典映射，记录每个键在RDD中的出现次数

-   `join(other, numPartitions=None)`

    链接两个RDD，结果集中只包含Key同时出现在两个RDD中的行。每一个key对应的结果是一个有两
    个value组成的元组。

-   `rightOuterJoin(other, numPartitions=None)`

    链接两个RDD，结果集中的key都来自other，如果key在源RDD中不存在，那么结果元组中的第一个值就
    是None

-   `leftOuterJoin(other, numPartitions=None)`

    链接两个RDD，结果集中的key都来自源RDD，如果key在other中不存在，那么结果元组中的第二个值就
    是None

-   `combineByKey(createCombiner, mergeValue, mergeCombiers)`

    按照k来合并元素。本函数以一个类型为（K,V）的RDD作为输入，以一个类型为（K,C）的RDD作为输出，
    参数createCombiner负责把类型V转换成类型C，mergeCombiners负责把两个C类型的值合并成一个C类
    型的值

-   `groupByKey(numPartitions=None)`

    按照K来对RDD中的元素进行分组

-   `cogroup(other, numPartitions=None)`

    按照Key来链接两个或者多个RDD。

Spark Streaming介绍
-------------------

实际场景中，如"双11"各大电商平台需要实时计算当前订单的情况，这需要对各个订单的数据依次进行采集、分析处理、存储等步骤，
对于数据处理的速度要求很高，而且需要保持一段时期内不间断的运行。对于这类问题，Spark通过Spark
Streaming组件提供了支 持，Spark
Streaming可以实现对于高吞吐量、实时的数据流的处理和分析，支持多样化的数据源如Kafka、Flume、HDFS、Kinesis和
Twitter等。

### DStream模型

类似于RDD之于Spark，Spark
Streaming也有自己的核心数据对象，称为DStream（Discretized
Stream，离散流）。 使用Spark
Streaming需要基于一些数据源创建DStream，然后在DStream上进行一些数据操作，这里的DStream可以近似地看作是一
个比RDD更高一级的数据结构或者是RDD的序列。

虽然Spark
Streaming声称是进行流数据处理的大数据系统，但从DStream的名称中就可以看出，它本质上仍然是基于批处理的。
DStream将数据流进行分片，转化为多个batch，然后使用Spark
Engine对这些batch进行处理和分析。

这里的batch是基于时间间隔来进行分割的，这里的批处理时间间隔（batch
interval）需要人为确定，每一个batch的数据对应一个RDD实例。

#### Input DStream

Input
DStream是一种特殊的DStream，它从外部数据源中获取原始数据流，连接到Spark
Streaming中。Input DStream可以接受两种 类型的数据输入：
（1）基本输入源：文件流、套接字连接和Akka Actor。
（2）高级输入源：Kafka、Flume、Kineis、Twitter等。

基本输入源可以直接应用于StreamingContext
API，而对于高级输入源则需要一些额外的依赖包。

由于Input DStream要接受外部的数据输入，因此每个Input
DStream（不包括文件流）都会对应一个单一的接收器（Receiver）对象，每
个接收器对象都对应接受一个数据流输入。由于接收器需要持续运行，因此会占用分配给Spark
Streaming的一个核，如果可用的核数不大于
接收器的数量，会导致无法对数据进行其他变换操作。

#### DStream变换

DStream的转换也和RDD的转换类似，即对于数据对象进行变换、计算等操作，但DStream的Transformation中还有一些特殊的操作，
如updateStateByKey()、transform()以及各种Window相关的操作。下面列举了一些主要的DStream操作：

  Transformation                       说明
  ------------------------------------ -----------------------------------------------------------------------------------------------------------------------------
  map(func)                            对DStream中的各个元素进行func函数操作，然后返回一个新的DStream.
  flatMap(func)                        与map方法类似，只不过各个输入项可以被输出为零个或多个输出项.
  filter(func)                         过滤出所有函数func返回值为true的DStream元素并返回一个新的DStream.
  repartition(numPartitions)           增加或减少DStream中的分区数，从而改变DStream的并行度.
  union(otherStream)                   将源DStream和输入参数为otherDStream的元素合并，并返回一个新的DStream.
  count()                              通过对DStream中的各个RDD中的元素进行计数.
  reduce(func)                         对源DStream中的各个RDD中的元素利用func进行聚合操作，然后返回只有一个元素的RDD构成的新的DStream.
  countByValue()                       对于元素类型为K的DStream，返回一个元素为（K,Long）键值对形式的新的DStream，Long对应的值为源DStream中各个RDD的key出现的次数.
  reduceByKey(func, \[numTasks\])      利用func函数对源DStream中的key进行聚合操作，然后返回新的（K，V）对构成的DStream.
  join(otherStream, \[numTasks\])      输入为（K,V)、（K,W）类型的DStream，返回一个新的（K，（V，W））类型的DStream.
  cogroup(otherStream, \[numTasks\])   输入为（K,V)、（K,W）类型的DStream，返回一个新的 (K, Seq\[V\], Seq\[W\]) 元组类型的DStream.
  transform(func)                      通过RDD-to-RDD函数作用于DStream中的各个RDD，返回一个新的RDD.
  updateStateByKey(func)               根据于key的前置状态和key的新值，对key进行更新，返回一个新状态的DStream.

Spark
Streaming提供了基于窗口（Window）的计算，即可以通过一个滑动窗口，对原始DStream的数据进行转换，得到一个新的DStream。
这里涉及到两个参数的设定： （1）窗口长度（window
length）：一个窗口覆盖的流数据的时间长度，必须是批处理时间间隔的倍数。
窗口长度决定了一个窗口内包含多少个batch的数据。
（2）窗口滑动时间间隔（slide
interval）：前一个窗口到后一个窗口所经过的时间长度，必须是批处
理时间间隔的倍数。

![image](window-slide-compute.jpg)

#### DStream输出操作

DStream的输出操作（Output
Operations）可以将DStream的数据输出到外部的数据库或文件系统。与RDD的Action类似，当某
个Output Operation被调用时，Spark Streaming程序才会开始真正的计算过程。

下面列举了一些具体的输出操作：

  Output Operations                       Interpretation
  --------------------------------------- ----------------------------------------------------------------------------------------
  print()                                 打印到控制台.
  saveAsTextFiles(prefix, \[suffix\])     保存DStream的内容为文本文件，文件名为"prefix-TIME
  saveAsObjectFiles(prefix, \[suffix\])   保存DStream的内容为SequenceFile，文件名为 "prefix-TIME
  saveAsHadoopFiles(prefix, \[suffix\])   保存DStream的内容为Hadoop文件，文件名为"prefix-TIME
  foreachRDD(func)                        对Dstream里面的每个RDD执行func，并将结果保存到外部系统，如保存到RDD文件中或写入数据库.

### 容错机制

容错（Fault
Tolerance）指的是一个系统在部分模块出现故障时仍旧能够提供服务的能力。一个分布式数据处理程序要能够长期不间断运
行，这就要求计算模型具有很高的容错性。

Spark操作的数据一般存储与类似HDFS这样的文件系统上，这些文件系统本身就有容错能力。但是由于Spark
Streaming处理的很多数据
是通过网络接收的，即接收到数据的时候没有备份，为了让Spark
Streaming程序中的RDD都能够具有和普通RDD一样的容错性，这些数据
需要被复制到多个Worker节点的Executor内存中。

Spark Streaming通过检查点（Check
Point）的方式来平衡容错能力和代价问题。DStream依赖的RDD是可重复的数据集，每一个RDD从
建立之初都记录了每一步的计算过程，如果RDD某个分区由于一些原因数据丢失了，就可以重新执行计算来恢复数据。随着运行时间的增加，
数据恢复的代价也会随着计算过程而增加，因此Spark提供了检查点功能，定期记录计算的中间状态，避免数据恢复时的漫长计算过程。
Spark Streaming支持两种类型的检查点：

（1）元数据检查点。这种检查点可以记录Driver的配置、操作以及未完成的批次，可以让Driver节点在失效重启后可以继续运行。

（2）数据检查点。这种检查点主要用来恢复有状态的转换操作，例如updateStateByKey或者reduceByKeyAndWindow操作，它可以
记录数据计算的中间状态，避免在数据恢复时，长依赖链带来的恢复时间的无限增长。

开启检查点功能需要设置一个可靠的文件系统路径来保存检查点信息，代码如下：

    streamingContext.checkpoing(checkPointDirectory)    //参数是文件路径

为了让Driver自动重启时能够开启检查点功能，需要对原始StreamingContext进行简单的修改，创建一个检查检查点目录的函数，代码如下：


    def functionToCreateContext(): StreamingContext = {
        val ssc = new StreamingContext(...)
        ssc.checkpoint(checkpointDirecroty)    //设置检查点目录
        ...
        val lines = ssc.socketTextStream(...)  //创建DStream
    }

    //从检查点目录恢复一个StreamingContext或者创建一个新的
    val ssc = StreamingContext.getOrCreate(checkpointDirectory,
                                          functionToCreateContext())
    //启动context
    context.start()
    context.awaitTermination()
