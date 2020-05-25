---
bibliography:
- 'ref.bib'
---

统计模型的MapReduce实现详解
===========================

MapReduce是大数据分布式计算的精髓所在。本章将以案例的形式着重介绍常用统计分析的MapReduce分
解。读者一旦熟悉了MapReduce逻辑，就可自行完成代码构建，提交Hadoop运行。本章的统计知识点涉及
回归分析中的逻辑斯蒂回归、泊松回归和岭回归方法、聚类分析、判别分析、朴素贝叶斯模型、推荐系
统。本章不会涉及统计方法的原理介绍，有需要的读者可以查看相应的文献
如@friedman2001elements、@hosmer2004applied、@jannach2010recommender等。

本章所使用的软件为统计常用的R与Python软件。其中涉及R软件使用的请参考@matloff2011art
@teetor2011r、涉及统计模型在R的实现请参考@james2013introduction;涉及推荐系统
的请参考@jannach2010recommender；涉及Python软件使用的请参
考@mckinney2012python或者@grus2015data、涉及网页数据获取的请参
考@mitchell2015web。

为了方便读者基于现有统计软件学习分布式计算，本章案例均采用Hadoop
Streaming接口，以保证所
有R和Python脚本可以在分布式系统中运行。值得说明的是本章以及之后章节所涉及的代码仅仅是为了阐
述方法和模型的示例性代码，在效率和结构很多方面有不完善之处，读者需要根据实际需求进一步完
善。
