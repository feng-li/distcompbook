分布式文件访问与计算
====================

Hive基础
--------

### Hive简介

Hive是Hadoop中的一个子项目，它建立在HDFS的分布式文件系统之上，可以用来进行数据提取转化加载（ETL）。
Hive 定义了自己的类 SQL 查询语言Hive
SQL（HQL），对于熟悉SQL语言的新用户非常友好。同时，HQL也允许熟 悉
MapReduce 开发的开发者自定义 mapper 和 reducer
来处理较为复杂的分析工作。Hive出现推动了Hadoop在 数据仓库方面的发展。

Hive最初是应Facebook每天产生的海量社会网络数据进行管理和挖掘的需求而产生和发展的。随着数据
量的增加，传统的MySQL、Oracle等数据库不再能满足数据爆发所带来的需求，Hadoop的出现解决了大数
据集的文件存储结构（HDFS）和计算模型（MapReduce）的问题。但是，如何从现有的数据基础架构
转移到Hadoop上仍然是一个挑战。Hive的出现解决了Hadoop的数据基础架构难题，它提供了HiveQL查询语言，能够帮助熟悉SQL的使用者更加快速地掌握Hive并进行查询；同时，这一
语言也允许熟悉MapReduce的开发者开发自定义的Mappers和Reducers来处理内建的Mappers和Reducers无
法完成的复杂的分析工作。

Hive作为一种数据仓库基础架构，为数据仓库的管理提供了很多功能：数据的ETL（抽取，转换和加载）工具、
数据存储管理和数据的查询分析等。Hive不是一个完整的数据库，其最大限制就是Hive不支持记录级别的更新、插入和删除
操作。同时，由于Hive是一个面向批处理的系统，MapReduce任务的启动过程需要消耗一定的时间，所
以Hive的查询延时比较严重，即使查询较小的数据集，也需要执行较长的时间。最后，Hive不支持联机事务处理，其过高的时间开销，限制了它对数据的即时查询能力，使其更接近于一个联机分析技术工具。
因此Hive是最适合数据仓库应用程序的，其可以维护海量数据，而且可以对数据进行挖掘，最后形成意
见和报告等。

由于 Hive 采用了类似关系型数据库SQL语言的查询语言 HQL，因此很容易将 Hive
理解为传统关系型数据库。其实Hive知识具有类似关系型数据库的外壳，两者在很多方面有着本质区别，清楚这一点，有助于从应用角度理解
Hive 的特性。

  对比项         Hive                      RDBMS
  -------------- ------------------------- --------------------------
  查询语言       HQL                       SQL
  数据存储位置   HDFS                      Raw Device 或者 Local FS
  数据格式       支持自定义                系统决定
  数据执行       MapRedcue                 Executor
  数据更新       覆盖追加                  行级别更新删除
  数据规模       大                        小
  索引           0.8版本之后支持简单索引   支持复杂的索引
  执行延迟       高                        低
  可扩展性       好                        差
  应用查询       海量离线查询              实时查询

  : Hive和关系型数据库RDBMS的异同[]{label="tab:Hive-RDBMS"}

-   查询语言 因为 SQL 被广泛的应用在关系型数据仓库中，因此 Hive
    特性设计了类 SQL 的查询语言 HQL，熟悉
    SQL语言的开发者可以很方便的使用 Hive 进行开发。

-   数据存储 Hive 是建立在 Hadoop 之上的，所有 Hive 的数据都是存储在
    HDFS 中的。而数据库则可以将数据保存在块设备或者本地文件系统中。

-   数据格式 Hive
    中没有定义专门的数据格式，数据格式可以由用户指定，用户定义数据格式需要指定三个属性：列分隔符（通常为空格、、行分隔符以及读取文件数据的方法（Hive
    中默认有三个文件格式 TextFile，SequenceFile 以及
    RCFile）。由于在加载数据的过程中，不需要从用户数据格式到 Hive
    定义的数据格式的转换，因此，Hive
    在加载的过程中不会对数据本身进行任何修改，而只是将数据内容复制或者移动到相应的
    HDFS
    目录中。而在数据库中，不同的数据库有不同的存储引擎，定义了自己的数据格式。所有数据都会按照一定的组织存储，因此，RDBMS数据库加载数据的过程会比较耗时。

-   数据更新 由于 Hive
    是针对数据仓库应用设计的，而数据仓库的内容是读多写少的。因此，Hive
    中不支持对数据的改写和添加，所有的数据都是在加载的时候中确定好的。而数据库中的数据通常是需要经常进行修改的，因此可以使用
    `INSERT INTO …VALUES` 添加数据，使用 `UPDATE …SET`修改数据

-   索引 Hive
    在加载数据的过程中不会对数据进行任何处理，甚至不会对数据进行扫描，因此也没有对数据中的某些
    Key 建立索引。Hive
    要访问数据中满足条件的特定值时，需要暴力扫描整个数据，因此访问延迟较高。由于
    MapReduce 的引入， Hive
    可以并行访问数据，因此即使没有索引，对于大数据量的访问，Hive
    仍然可以体现出优势。数据库中，通常会针对一个或者几个列建立索引，因此对于少量的特定条件的数据的访问，数据库可以有很高的效率，较低的延迟。由于数据的访问延迟较高，决定了
    Hive 不适合在线数据查询。

-   执行 Hive 中大多数查询的执行是通过 Hadoop 提供的 MapReduce
    来实现的（类似 select \* from tbl 的查询不需要
    MapReduce）。而数据库通常有自己的执行引擎。

-   可扩展性 因为 Hive 是建立在 Hadoop 之上的，因此 Hive 的可扩展性是和
    Hadoop 的可扩展性是一致的。而数据库由于 ACID
    语义的严格限制，扩展行非常有限。目前最先进的并行数据库 Oracle
    在理论上的扩展能力也只有 100 台左右。

-   数据规模与应用场景 Hive 建立在集群上并可以利用 MapReduce
    进行并行计算，因此可以支持很大规模的数据；对应的，数据库可以支持的数据规模较小。所以Hive
    适合用来做海量离线数据统计分析，也就是数据仓库。

本书选择CLI方式与Hadoop进行交互。CLI为命令行界面，Hive提供图形化用户界面，如Hue项目，Hive的Thrift
服务等。对于Hive的其他文献请参考@capriolo2012programming,@du2015apache等。

### Hive数据类型

Hive支持关系型数据库中的大多数基本数据类型，同时也支持集合数据类型，对于数据在文件中的编码
方式具有非常大的灵活性。

  数据类型      描述
  ------------- ----------------------------------------------------
  `TINYINT`     1byte，有符号整数，如20
  `SMALINT`     2byte，有符号整数，如20
  `INT`         4byte，有符号整数，如20
  `BIGINT`      8byte，有符号整数，如20
  `BOOLEAN`     布尔类型，TRUE或FALSE
  `FLOAT`       4byte单精度浮点数，如3.14159
  `DOUBLE`      8byte双精度浮点数，如3.14159
  `STRING`      字符序列，如"hive","hadoop"
  `BINARY`      字节数组，注V0.8.0以上版本支持
  `TIMESTAMP`   时间戳，整数，浮点数活字符串，注V0.8.0以上版本支持

  : Hive基本数据类型[]{label="tab:hive-data-strc"}

  数据类型   描述
  ---------- -----------------------------------------------------
  STRUCT     一组命名字段，字段类型可以不同，如struct('a',1,1,0)
  MAP        一组键值对元组集合，其中键的类型必须是原子数据类型
  ARRAY      一组有序字段，字段类型必须相同，如array('a','b')

  : Hive集合数据类型[]{label="tab:hive-set-data-strc"}

HiveQL 数据定义（DDL）
----------------------

### 数据库的定义

#### 创建数据库

Hive中数据库的概念本质上是表的一个目录或命名空间，这样的结构能够避免表命名冲突，将生产表组
织成逻辑组。

创建数据库的语法为：

        Hive> CREATE (DATABASE|SCHEMA) [IF NOT EXISTS] database_name
        [COMMENT database_comment][LOCATION hdfs_path]
        [WITH DBPROPERTIES (property_name=property_value, ...)];

我们可以查看现有的数据库：

        Hive> SHOW DATABASES;

创建数据库时，如果数据库已存在，会抛出错误信息，使用下面的语句可以避免抛出错误信息

        Hive> CREATE DATABASE IF NOT EXISTS test;

查看数据库时，如果记不清数据库名称，可使用正则表达式匹配筛选：

        Hive> SHOW DATABASES LIKE 't.*';

此外，创建数据库时还可增加数据库的描述信息（COMMENT），指定数据库创建位置（LOCATION），增加
键值对属性信息（WITH DBPROPERTIES）等。

数据库创建后，可使用USE语句选择当前操作所需的数据库：

        Hive> USE test;

Hive不提供语句查看用户当前所处的数据库，但可使用下面的方式查看当前所在的数据库:

        Hive> set hive.cli.print.current.db=true;
        Hive> set hive.cli.print.current.db=false;

#### 修改数据库

`ALTER DATABASE`命令可进行数据库的修改，但是只能修改键值对属性值，数据库名和所在的目
录位置都不能修改。语法结构为：

        Hive> ALTER (DATABASE|SCHEMA) database_name SET DBPROPERTIES (property_name=property_value, ...);
        Hive> ALTER (DATABASE|SCHEMA) database_name SET OWNER [USER|ROLE] user_or_role;

`DESCRIBE`命令可查看数据库的描述信息和文件目录位置路径信息：

        Hive> DESCRIBE DATABASE TEST;

为数据库的DBPROPERTIES设置键-值对属性值：

        Hive> ALTER DATABASE test SET DBPROPERTIES ('edited-by'='user2');

重新查看数据库信息：

        Hive> DESCRIBE DATABASE EXTENDED TEST;

#### 删除数据库

数据库的删除使用`DROP`命令，语法为：

        Hive> DROP (DATABASE|SCHEMA) [IF EXISTS] database_name [RESTRICT|CASCADE];

与创建数据库类似，添加`IF EXISTS`子句可避免因数据库不存在而抛出警告信息:

        Hive> DROP DATABASE IF EXISTS test;

当数据库中包含表时，Hive不允许删除，可添加`CASCADE`子句进行删除：

        Hive> DROP DATABASE IF EXISTS test CASCADE;

### 表的定义

#### 创建表

Hive对SQL中的CREATE
TABLE语句做了功能扩展，例如定义表的存储位置、存储格式等。Hive的创建表完
整语句结构如下：

        Hive> CREATE [TEMPORARY] [EXTERNAL] TABLE [IF NOT EXISTS] [db_name.]table_name
        [(col_name data_type [COMMENT col_comment], ...)]
        [COMMENT table_comment]
        [PARTITIONED BY (col_name data_type [COMMENT col_comment], ...)]
        [CLUSTERED BY (col_name, col_name, ...) [SORTED BY (col_name [ASC|DESC], ...)] INTO num_buckets BUCKETS]
        [SKEWED BY (col_name, col_name, ...)
        ON ((col_value, col_value, ...), (col_value, col_value, ...), ...)
        [STORED AS DIRECTORIES]
        [[ROW FORMAT row_format]
        [STORED AS file_format]| STORED BY'storage.handler.class.name'[WITH SERDEPROPERTIES (...)]]
        [LOCATION hdfs_path]
        [TBLPROPERTIES (property_name=property_value, ...)]
        [AS select_statement];

首先，创建表前需明确当前所处的数据库是否是目标数据库，如果不是，可通过在表前增加一个数据库
名进行指定。与数据库的定义方式类似，`IF NOT EXISTS`选项用于判断数据库是否已存在创建
名字的表，如果已存在，Hive会忽略后面的执行语句，就算已存在的表和后面的执行语句指定的模式不
同，Hive也会忽略这个差异。

`LOCATION`可用于指定存储的路径,默认情况下创建的表会放在所在数据库目录之后。
例如，在数据库testdb下创建表table1，其中，table1由name和grade组成：

        Hive> CREATE TABLE IF NOT EXISTS testdb.table1 (name STRING,grade INT);

`TEMPORARY/EXTERNAL`关键字是用以控制创建外部表或内部表的控制参数。默认情况下
为`TEMPORARY`，构建内部表。内部表由Hive控制生命周期，将数据移动到数据仓库指向的路径。
当我们对内部表执行删除操作时，表中的数据也会被一并删除。与内部表不同，`EXTERNAL`
在
创建外部表时，需指定数据指向路径，Hive读取`LOCATION`后整个目录的下的文件并加载到表中。
当对外部表进行删除时，仅删除了元数据，而数据并没有什么影响。外部表的创建方式方便与别的工作
进行共享数据，但有的HiveQL语法结构并不适用于外部表。

`PARTITIONED`关键字用以进行表的分区，提高查询性能。对于内部表而言，分区表改变Hive对数据存储的组织方式，Hive会根据分区情况创建好对应表格路径下的子目录。对于外部表而言，用户可以根据自己的需求自行定义目录结构，灵活性更高。如日志数据按日期分区，公司人力数据按部门进行分区等。
以建立一个公司员工表格为例：

        Hive> CREATE TABLE IF NOT EXISTS test.Employee (
        name STRING,
        salary FLOAT COMMENT 'UPDATE ONCE A MONTH',
        address STRUCT<street:STRING,city:STRING,state:STRING>)
        LOCATION '/Users/hive/warehouse/test/employee';

上面的语句在test数据库中创建了Employee表格，表格包含三个字段，分别是姓名、工资和地址；表格建立在指定的工作路径下。

#### 删除和修改表

同SQL语句，Hive支持`DROP TABLE`命令操作进行表的删除。删除上面简历的员工表：

        Hive> DROP TABLE Employee;

通过`SHOW TABLES`语句查看当下数据库中的表格已不再存在`Employee`表。
表的修改可修改大多数的表属性，修改只会修改元数据，不会对数据产生影响。以下列出修改表常用语
句命令以及例子

-   重命名 `RENAME`

        Hive> ALTER TABLE table1 RENAME TO table2;

-   增加表的分区 `ADD PARTITION`

        Hive> ALTER TABLE log_message ADD PARTITION (year=2015,month=7,day=1)
            LOCATION ‘/logs/2015/7/1’;

-   移动表分区 `SET LOCATION`

        Hive> ALTER TABLE log_message PARTITION(year=2015,month=7,day=1)
            SET LOCATION ‘/Users/hive/logs/2015/07/01’;

-   删除表分区 `DROP PARTITION`

        Hive> ALTER TABLE log_message DROP PARTITION(year=2015,month=7,day=1);

-   修改列信息

    -   (重命名，修改位置、类型或注释) `CHANGE COLUMN`

            Hive> ALTER TABLE log_message CHANGE COLUMN log_time INT;

    -   增加列 `ADD COLUMNS`

            Hive> ALTER TABLE log_message ADD COLUMN (app_name STRING);

    -   替换列 `REPLACE COLUMN`

            Hive> ALTER TABLE log_message REPLACE COLUMNS( messages STRING);

### HiveQL 数据操作（DML）

#### 从本地文件系统中导入数据

向Hive中已存在的表中导入数据，只需使用`LOAD DATA`关键字进行即可。Hive不支持行级别的
数据输入、删除等操作，即不支持`INSERT INTO…VALUES`形式的操作，因此不得不使用数据装载
操作。我们以下面的例子展示此过程：

1.  随机创建一个空文件，输入依次输入姓名、性别和工资数据；存储在电脑中。（分隔符设定为空
    格）

        LiXiang 1 6732
        WangXiaoHong 1 5743
        HeFeng 2 3329

2.  创建表：

        Hive> CREATE TABLE income(
            name STRING,
            sex INT,
            salary INT)
            ROW FORMAT DELIMITED FIELDS TERMINATED BY ' '
            STORED AS TEXTFILE;

3.  将第一步生成的随机数导入表：

        Hive> LOAD DATA LOCAL INPATH '/Users/caoxin/Desktop/HIVE/employee' into table income;

这样我们输入的文本信息就导入到income表中了。此时的`LOCAL`关键字如果省略则指分布式文
件系统中的路径。

        Hive> select * from income;

此外，还可在语句中增加`OVERWRITE、PARTITION`等关键字进行数据的导入。在导入数据时使
用`OVERWRITE`，目标表中的内容会被删除再进行新的添加。`PARTITION`后的分区目录
如果不存在，这个命令会先创建分区目录，再继续数据的拷贝。

#### 从HDFS上导入数据到Hive表

从本地文件系统中导入数据到Hive的过程，其实是先将数据临时复制到HDFS的一个目录下，然后再将数据从那个临时目录下移动到对应的Hive表的数据目录里面。假设我们的HDFS中已存在文件Datatest.txt，则直接可通过下面的命令将这个文件导入到Hive中：

        Hive> LOAD DATA INPATH 'home/Datatest.txt' INTO TABLE datatest

仔细观察可发现，这种导入方式与上面的区别仅在于文件的路径前是否有LOCAL关键字。

#### 通过查询语句向表中插入数据

Hive尽管不支持`INSERT INTO VALUE`这种结构，但是`INSERT`语句允许用户通过查询语句向目标
表中插入数据。如将数据库中datatest表中的id,age数据取出插入另一个表dataid中:

        Hive> INSERT INTO table dataid
        partition (age)
        select id,age from datetest;

这种方法也叫做动态分区插入，使用前需要将`hive.exec.dynamic.partition.mode`设置
成`nonstrict`。同直接插入外部数据，此时也支持`OVERWRITE`关键字进行覆盖操作。

#### 通过查询创建表

在实际操作时，若表的查询输出结果过多，则可创建一个新的表用来存储查询的结果，该情况
称为`CTAS（CREATE TABLE … AS SELECT）`。在我们的工作中使用频率很高。

#### 导出数据

如果从Hive需要导出的文件是用户需要的格式，则直接使用终端命令拷贝文件夹或文件即可。

        $ hadoop fs -cp source_path target_path

如若不是，则可使用`INSERT…DIRECTORY…`命令。基本结构如 下：

        Hive> INSERT (OVERWRITE) LOCAL DIRECTORY… SELECT … FROM … WHERE…

### HiveQL 数据查询

在了解了Hive的基本概念、数据定义等相关内容后，我们进入数据查询的介绍。作为统计背景的学生，
查询操作是我们日后工作中必须掌握的工作技能之一，这里HiveQL与SQL中的大部分功能相同，本部分我
们的重点将放在传统SQL与HiveQL的差异上。

HiveQL中的标准查询语句语法定义如下：

        Hive> SELECT [ALL | DISTINCT] select_expr, select_expr, ...
        FROM table_reference
        [WHERE where_condition]
        [GROUP BY col_list]
        [CLUSTER BY col_list
         | [DISTRIBUTE BY col_list] [SORT BY col_list]
        ]
        [LIMIT number]

`SELECT FROM`操作与SQL中相同，`WHERE`为条件子句，用以过滤条件。`GROUP BY`子句通常会和聚合函数一起使用，按照一个或多种列对结果进行分组，然后再对每个组执行聚合操
作。实际工业应用中，一个查询往往返回海量数据，LIMIT可用于限制返回的行数，提高查询效
率。Hive支持所有典型的算术运算符，包括加、减、乘、除、求余等。进行算术运算时，用户需要注意
数据溢出或数据下溢问题。此外，Hive内置许多数学函数，表 [\[tab:hive-math-fun\]](#tab:hive-math-fun){reference-type="ref"
reference="tab:hive-math-fun"}中包括了比较 常见的数学函数。

  函数                                          说明
  --------------------------------------------- -----------------------------------------------------------------------------------
  `round(double a)`                             四舍五入
  `floor(double a)`                             向下取整
  `ceil(double a)`                              向上取整
  `exp(double a)`                               e的n次方
  `sqrt(double a)`                              数值的平方根
  `abs(double a)`                               取绝对值
  `year(string date)`                           返回指定的年份，同理，`month/day/hour/minute/second`返回对应的月份、日期、 小时等
  `weekofyear(string date)`                     返回指定日期所在一年中的星期号
  `datediff(string enddate,string startdate)`   两个时间参数的日期之差
  `length(string a)`                            字符串长度

  : Hive常用数学函数[]{label="tab:hive-math-fun"}

聚合函数是一类比较特殊的函数，其可以对多行进行一些计算，然后得到一个结果。我们常用的两个例子为count和avg函数，分别可用于计算样本数量和平均数。例如计算表内用户总数，可使用count计算有多少行数据。下面的示例用以查询表中有多少用户：

        Hive> select count(*) from user_info;

此外，常用的聚合函数还包括SUM、MIN、MAX等，聚类函数常与GROUP
BY联合使用，按照一个或多个列的
结果进行分组，然后对每个组执行聚合操作。如下面的例子就是按年份分组后查询平均价格：

        Hive> select year(ymd),avg(price) from stocks
            group by year(ymd);

Hive中的嵌套等方式与SQL一致，在此不再赘述。

#### 表的连接

在SQLServer数据库中，我们已经学过的相关的表连接概念，如内连接、外连接、左外连接，笛卡尔积连
接等。标准SQL支持对连接关键词进行非等值连接，但Hive不支持。此外，Hive也不支持在ON子句的谓语
间使用OR。

由于Hive假定查询中最后的一个表是最大的表，因此，若保证连续查询中的表大小从左到右依次是增加
的，可提高Hive的连接速率。Hive中提供`/*streamtable(表名)*/`这种标记机制来显式地告知
查询哪张是大表，作为驱动表。

在标准SQL中，我们还会常常用到IN语句，用来判断做连接时，存在才输出这种情况，但是Hive中不支
持IN的连接查询，此时我们可用`LEFT SEMI JOIN`替代。

        Hive> select * from table1 left semi join table2
            on (table1.sno1=table2.sno2);

这个连接与左外连接的区别在于有过滤机制，需判断主键在右表中是否存在，存在则打印，不存在则过
滤掉。为了优化连接，Hive还支持map-side
JOIN操作（/\*MAPJOIN(表名)\*/）。如果表中有一张是小表，
可以在最大的表通过mapper时将小表完全放在内存中，当另外一个表的数据与小表进行连接时，可以直接和内存中
的表数据做匹配，此时只需要mapper，节约了reducer的时间，并减少了map过程的执行步骤。

#### UNION

在实际使用中，我们有时还需要进行表的合并。这时`UNION ALL`语句就可以将2个或多个表合并在一起，
在合并时，需保证UNION的各个表直接具有相同的列，且对应的每列的数据类型必须是一致的。

#### SORT BY

在Hive的使用过程中应避免使用`ORDER BY`语句。`ORDER BY`会将所有数据通过一个reducer进行处理，在数
据集比较大时，容易消耗太多的时间执行，查询效率低下。但是，`SORT BY`的排序方式在在每一
次reduce中进行一次局部排序，保证每个reducer的输出数据是有序的，提高了全局排序的效率。

Hive调优
--------

Hive简单容易上手：提供了类SQL查询语言HQL，同时为超大数据集设计了计算/扩展能力（MR作为计算引擎，HDFS作为存储系统），但是Hive自动生成的mapreduce作业，通常情况下不够智能化，同时在HQL上的表达能力有限，有些情况出现ive效率低下，查询慢的情况。

### Hive运行变慢的原因

考虑到HADOOP计算框架特性，在Hadoop平台上数据量大不是问题，数据倾斜是个问题（尤其是Reduce端）。当jobs数比较多是，作业运行效率相对比较低，比如即使有几百行的表，如果多次关联多次汇总，产生十几个jobs，耗时很长。原因是mapreduce作业初始化的时间是比较长的。
但是sum,count,max,min等UDAF，不怕数据倾斜问题,hadoop在map端的汇总合并优化（类似于Combiner），使数据倾斜不成问题。
count(distinct ),在数据量大的情况下，效率较低，如果是多count(distinct
)效率更低。

#### 问题场景及优化方案

针对Hive查询中可能遇到的问题场景，以下针对性的提出了一些优化思路

-   OOM导致作业失败

    OOM发生的主要原因是Child内存超限，默认1650MB。可以通过abaci.job.map/reduce.memory.mb和abaci.job.map/reduce.child.memory.mb配套调整，设置成一样的值，保证【调度内存】和【限制内存】一致，前者控制【调度内存】；后者控制【限制内存】。两者统一保证单机不会超发太多

-   输入文件数量多，其中很多是远远小于256M的小文件

    当输入为大量小文件（HDFS中文件块大小为256M）时会导致map数据过多而查询缓慢，这时通过调整文件块大小，对未达到阈值的小文件进行合并，减少map数

            Hive> set mapred.max.split.size=100000000;
                    set mapred.min.split.size.per.node=100000000;
                    set mapred.min.split.size.per.rack=100000000;
                    set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;---表示执行前进行小文件合并

    前面三个参数确定合并文件块的大小，大于文件块大小256M的，按照256M来分隔，小于256M,大于100M的，按照100M来分隔，把那些小于100M的（包括小文件和分隔大文件剩下的）进行合并。

-   需要调节reduce数量

    调整原则：使大数据量利用合适的reduce数；使单个reduce任务处理合适的数据量
    动态设置：

            Hive> set hive.exec.reducers.bytes.per.reduce =500000000; （500M）;

    静态设置：

            Hive> set mapred.reduce.tasks = 15;

    前者是通过控制每个reduce处理的数据量来控制reduce数，后者是直接指定reduce数量
    当数据量小于hive.exec.reducers.bytes.per.reducer参数值，只有一个reduce

-   输出小文件合并参数

    文件数目过多，会给 HDFS 带来压力，并且会影响处理效率，可以通过合并
    Map 和 Reduce 的结果文件来消除这样的影响：

            Hive> hive.merge.mapfiles = true; ---是否和并 Map 输出文件，默认为 True
                    hive.merge.mapredfiles = false; ---是否合并 Reduce 输出文件，默认为 False
                    hive.merge.size.per.task = 256*1000*1000; --- 合并文件的大小

-   动态分区的使用

    Hive分区是在创建表的时候用Partitioned by
    关键字定义的，如果用这种静态分区，插入的时候必须首先要知道有什么分区类型，而且每个分区写一个load
    data，比较繁琐。使用动态分区可解决以上问题，其可以根据查询得到的数据动态分配到分区里。其实动态分区与静态分区区别就是不指定分区目录，由系统自己选择。针对动态分区的使用可以调用以下命令：

            Hive> set hive.exec.dynamic.partition=true; ---是否在DDL/DML操作中打开动态分区。
                    set hive.exec.dynamic.partition.mode=nostrick ; ---打开动态分区后，动态分区的模式，有 strict 和 nonstrict 两个值可选，strict要求至少包含一个静态分区列，nonstrict 则无此要求。
                    set hive.exec.max.dynamic.partitions=1000; ---所允许的最大的动态分区的个数。
                    set hive.exec.max.dynamic.partitions.pernode=100; ---单个 reduce 结点所允许的最大的动态分区的个数。

-   大小表join，建议使用mapjoin

    小表关联一个超大表时，容易发生数据倾斜，可以用MapJoin把小表全部加载到内存在map端进行join，避免reducer处理
    1.如果是小表，自动选择Mapjoin：sethive.auto.convert.join=true;
    默认为false 2.设置小表阀值： set
    hive.mapjoin.smalltable.filesize=25000000; 默认值是25M; 语法 select
    /\*+ MAPJOIN(小表名) \*/ 字段1，字段2 from 大表 ；

-   数据倾斜问题

    数据倾斜现象：某一个或某几个reduce作业处理的数据量远高于其他。
    数据倾斜原因:分布不均匀、业务数据本身就有倾斜、有些sql语句本省就会产生数据倾斜。
    常见数据倾斜场景：使用join和group by时。比如group
    by时某个取值数量就是很多，这样不可避免的就有数据倾斜。

    1.  调节参数： （1）设置hive.map.aggr = true，在 Map
        端进行聚合，也就是combiner造作。这样就会使得在reduce端的数据量有效的减少，可以一定程度上缓解数据倾斜的程度。
        （2）
        设置hive.groupby.skewindata=true，这样当有数据倾斜时就会进行负载均衡。如在group
        by时出现数据倾斜了，就可以把延时很长的作业分配一部分给其他已经完成的reduce做，最后再聚合结果。

    2.  处理key分布不均匀 group by key或者join on
        key时，对于key中有空值或者数据量明显过多的key可以在原来的值得基础上加一个随机数，这样就可以把倾斜的数据分不到不同的reduce上，只是最后要把结果还原。

                SELECT CASE
                        WHEN deal_id IS NULL THEN concat('null',rand()%5)
                        ELSE deal_id
                    END,
                    count(1)
                FROM nuomi.test
                WHERE ds = '20160519'
                GROUP BY CASE
                        WHEN deal_id IS NULL THEN concat('null',rand()%5)
                        ELSE deal_id
                END

        这个例子中，因为发现deal\_id大量的是空值，造成数据倾斜，所以把为空的key随机的分布到5个reduce作业中。

    3.  join优化 选用join
        key分布最均匀的表作为驱动表，并且大表放在右边，小表放在左边。可以采用mapjoin。

    4.  排序优化 QE任务中禁止使用 order by，可以用sort
        by操作，然后结合distribute by作为reduce分区键。

Hive 内置函数与UDF函数
----------------------

Hive内部提供了很多函数给开发者使用，包括数学函数，类型转换函数，条件函数，字符函数，聚合函数，表生成函数等等，这些函数都统称为内置函数。Hive中的内置函数正常情况下已经能满足日常需求，但如果需要更加个性化的函数则需要使用用户自定义函数(User
Define Function)。

### Hive内置运算符

-   Hive内置关系运算

      运算符           语法            操作类型       描述
      ---------------- --------------- -------------- --------------------------------------------------------------------------------------------------------------------------------------------------------------
      等值比较         A = B           所有基本类型   如果表达式A与表达式B相等，则为TRUE；否则为FALSE
      不等值比较       A \<\> B        所有基本类型   如果表达式A为NULL，或者表达式B为NULL，返回NULL；如果表达式A与表达式B不相等，则为TRUE；否则为FALSE
      小于比较         A \< B          所有基本类型   如果表达式A为NULL，或者表达式B为NULL，返回NULL；如果表达式A小于表达式B，则为TRUE；否则为FALSE
      小于等于比较     A \<= B         所有基本类型   如果表达式A为NULL，或者表达式B为NULL，返回NULL；如果表达式A小于或者等于表达式B，则为TRUE；否则为FALSE
      大于比较         A \> B          所有基本类型   如果表达式A为NULL，或者表达式B为NULL，返回NULL；如果表达式A大于表达式B，则为TRUE；否则为FALSE
      大于等于比较     A \>= B         所有基本类型   如果表达式A为NULL，或者表达式B为NULL，返回NULL；如果表达式A大于或者等于表达式B，则为TRUE；否则为FALSE
      空值判断         A IS NULL       所有类型       如果表达式A的值为NULL，则为TRUE；否则为FALSE
      非空判断         A IS NOT NULL   所有类型       如果表达式A的值为NULL，则为FALSE；否则为TRUE
      LIKE比较         A LIKE B        strings        如果字符串A或者字符串B为NULL，则返回NULL；如果字符串A符合表达式B 的正则语法，则为TRUE；否则为FALSE。B中字符"\_"表示任意单个字符，而字符"%"表示任意数量的字符
      JAVA的LIKE操作   A RLIKE B       strings        如果字符串A或者字符串B为NULL，则返回NULL；如果字符串A符合JAVA正则表达式B的正则语法，则为TRUE；否则为FALSE
      REGEXP操作       A REGEXP B      strings        功能与RLIKE相同

      : 关系运算[]{label="tab:Hive-Relational Operators"}

-   Hive 内置数学运算

      运算符       语法       操作类型                                             描述
      ------------ ---------- ---------------------------------------------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      加法操作     A + B      所有数值类型                                         返回A与B相加的结果。结果的数值类型等于A的类型和B的类型的最小父类型（详见数据类型的继承关系）。比如，int + int 一般结果为int类型，而 int + double 一般结果为double类型
      减法操作     A \<\> B   所有数值类型                                         返回A与B相减的结果。结果的数值类型等于A的类型和B的类型的最小父类型（详见数据类型的继承关系）。比如，int -- int 一般结果为int类型，而 int -- double 一般结果为double类型
      乘法操作     A \* B     所有数值类型                                         返回A与B相乘的结果。结果的数值类型等于A的类型和B的类型的最小父类型（详见数据类型的继承关系）。注意，如果A乘以B的结果超过默认结果类型的数值范围，则需要通过cast将结果转换成范围更大的数值类型
      除法操作     A / B      所有数值类型                                         返回A除以B的结果。结果的数值类型为double
      取余操作     A % B      所有数值类型                                         返回A除以B的余数。结果的数值类型等于A的类型和B的类型的最小父类型（详见数据类型的继承关系）
      位与操作:    A & B      所有数值类型                                         返回A和B按位进行与操作的结果。结果的数值类型等于A的类型和B的类型的最小父类型（详见数据类型的继承关系）
      位或操作     A \| B     所有数值类型                                         返回A和B按位进行或操作的结果。结果的数值类型等于A的类型和B的类型的最小父类型（详见数据类型的继承关系）
      位异或操作   A B̂        所有数值类型                                         返回A和B按位进行异或操作的结果。结果的数值类型等于A的类型和B的类型的最小父类型（详见数据类型的继承关系）
      位取反操作    A         返回A按位取反操作的结果。结果的数值类型等于A的类型   

      : 数学运算[]{label="tab:Hive-Arithmetic Operators"}

-   Hive 内置逻辑运算

      运算符       语法      操作类型                                           描述
      ------------ --------- -------------------------------------------------- -------------------------------------------------------------------------
      逻辑与操作   A AND B   boolean                                            如果A和B均为TRUE，则为TRUE；否则为FALSE。如果A为NULL或B为NULL，则为NULL
      逻辑或操作   A OR B    boolean                                            如果A为TRUE，或者B为TRUE，或者A和B均为TRUE，则为TRUE；否则为FALSE
      逻辑非操作   NOT A     如果A为FALSE，或者A为NULL，则为TRUE；否则为FALSE   

      : 逻辑运算[]{label="tab:Hive-Logical Operators"}

### Hive内置函数

-   Hive 内置数学函数

    常用的数学函数包括：取整函数: round；取随机数函数:
    rand；自然指数函数: exp；对数函数: log；幂运算函数: pow；开平方函数:
    sqrt；二进制函数: bin；绝对值函数: abs；正取余函数: pmod；余弦函数:
    cos等。

-   Hive 内置日期函数 常用的日期函数包括：UNIX时间戳转日期函数:
    from\_unixtime；日期转UNIX时间戳函数:
    unix\_timestamp；日期时间转日期函数: to\_date；日期比较函数:
    datediff等。

-   Hive 内置字符串函数
    常见的字符串函数包括：字符串长度函数：length；字符串截取函数：substr,substring；字符串转大写函数：upper,ucase；正则表达式替换函数：regexp\_replace等。

-   Hive 内置条件函数

      函数名称       语法                                                      返回值                                                       描述
      -------------- --------------------------------------------------------- ------------------------------------------------------------ ----------------------------------------------------------------------
      If函数         A AND B                                                   if(boolean testCondition, T valueTrue, T valueFalseOrNull)   当条件testCondition为TRUE时，返回valueTrue；否则返回valueFalseOrNull
      非空查找函数   COALESCE(T v1, T v2, ...)                                 T                                                            返回参数中的第一个非空值；如果所有值都为NULL，那么返回NULL
      条件判断函数   CASE a WHEN b THEN c \[WHEN d THEN e\]\* \[ELSE f\] END   T                                                            如果a等于b，那么返回c；如果a等于d，那么返回e；否则返回f
      条件判断函数   CASE WHEN a THEN b \[WHEN c THEN d\]\* \[ELSE e\] END     T                                                            如果a为TRUE,则返回b；如果c为TRUE，则返回d；否则返回e

      : 条件函数[]{label="tab:Hive-Conditional Functions"}

-   Hive 内置集合统计函数

    1.  个数统计函数 语法：count(\*), count(expr), count(DISTINCT
        expr\[, expr\_.\]) 返回值: int 说明:
        count(\*)统计检索出的行的个数，包括NULL值的行；count(expr)返回指定字段的非空值的个数；count(DISTINCT
        expr\[, expr\_.\])返回指定字段的不同的非空值的个数

            hive> select count(*) from eblog;
            10
            hive> select count(distinct t) from eblog;
            2

    2.  总和统计函数 语法: sum(col), sum(DISTINCT col) 返回值: double
        说明: sum(col)统计结果集中col的相加的结果；sum(DISTINCT
        col)统计结果中col不同值相加的结果

            hive> select sum(t) from eblog;
            100
            hive> select sum(distinct t) from eblog;
            70

    3.  平均值统计函数 语法: avg(col), avg(DISTINCT col) 返回值: double
        说明: avg(col)统计结果集中col的平均值；avg(DISTINCT
        col)统计结果中col不同值相加的平均值

            hive> select avg(t) from eblog;
            50
            hive> select avg (distinct t) from eblog;
            30

    4.  最小值统计函数 语法: min(col) 返回值: double 说明:
        统计结果集中col字段的最小值

            hive> select min(t) from eblog;
            20

    5.  最大值统计函数 语法: maxcol) 返回值: double 说明:
        统计结果集中col字段的最大值

            hive> select max(t) from eblog;
            120

    6.  非空集合总体变量函数 语法: var\_pop(col) 返回值: double 说明:
        统计结果集中col非空集合的总体变量（忽略null）

    7.  非空集合样本变量函数 语法: var\_samp (col) 返回值: double 说明:
        统计结果集中col非空集合的样本变量（忽略null）

    8.  总体标准偏离函数 语法: stddev\_pop(col) 返回值: double 说明:
        该函数计算总体标准偏离，并返回总体变量的平方根，其返回值与VAR\_POP函数的平方根相同

    9.  样本标准偏离函数 语法: stddev\_samp (col) 返回值: double 说明:
        该函数计算样本标准偏离

    10. 中位数函数 语法: percentile(BIGINT col, p) 返回值: double 说明:
        求准确的第pth个百分位数，p必须介于0和1之间，但是col字段目前只支持整数，不支持浮点数类型

    11. 中位数函数（百分位） 语法: percentile(BIGINT col, array(p1 \[,
        p2\]...)) 返回值: array\<double\> 说明:
        功能和上述类似，之后后面可以输入多个百分位数，返回类型也为array\<double\>，其中为对应的百分位数。

    12. 中位数函数（百分位） 语法: percentile(BIGINT col, array(p1 \[,
        p2\]...)) 返回值: array\<double\> 说明:
        功能和上述类似，之后后面可以输入多个百分位数，返回类型也为array\<double\>，其中为对应的百分位数。

            hive> select percentile(score,&lt;0.2,0.4>) from eblog； -- 取0.2，0.4位置的数据

    13. 近似中位数函数 语法: percentile\_approx(DOUBLE col, p \[, B\])
        返回值: double 说明:
        求近似的第pth个百分位数，p必须介于0和1之间，返回类型为double，但是col字段支持浮点类型。参数B控制内存消耗的近似精度，B越大，结果的准确度越高。默认为10,000。当col字段中的distinct值的个数小于B时，结果为准确的百分位数

    14. 近似中位数函数（百分位） 语法: percentile\_approx(DOUBLE col,
        array(p1 \[, p2\]...) \[, B\]) 返回值: array\<double\> 说明:
        功能和上述类似，之后后面可以输入多个百分位数，返回类型也为array\<double\>，其中为对应的百分位数。

    15. 直方图 语法: histogram\_numeric(col, b) 返回值: array\<struct
        'x','y'\> 说明: 以b为基准计算col的直方图信息。

            hive> select histogram_numeric(100,5) from eblog;
            [{"x":100.0,"y":1.0}]

### Hive自定义函数

hive允许用户使用自定义函数解决hive
自带函数无法处理的逻辑。hive自定义函数只在当前线程内临时有效，可以使用shell脚本调用执行hive命令。具体包括UDF、UDAF和UDTF

-   UDF 输入一行数据输出一行数据

-   UDAF 输入多行数据输出一行数据，一般在group by中使用

-   UDTF 用来实现一行输入多行输出
