---
layout: post
title: 分布式爬虫系统
date: 2016-10-11 23:23:07 +0800
categories: note program
---
构建于进程模型上，就接近分布式了。

## 爬虫
- scrapy: python的爬虫类库，需改造成符合分布式的持久运行进程。可参考scrapy-redis项目。
- docker_scrapyd: scrapyd 的docker封装，一键部署，扩展，迁移。
- scrapydsched: scrapyd进程调度，控制各个scrapyd上的进程数。
- redis: src链接队列，爬取任务启动。
- kafka MQ: 消息队列。可用于消息订阅及后续分析，存储。
- pykafkamini: pykafka的包装，方便各种测试。
- kafkamsgsel: kafka消息选择算法封装，供各个前端调用。

## 前端
- docker_flask: flask运行环境的docker封装，运行微信。

## 内部支持
- zrpcscrapyenv: 个人项目，内部rpc链接scrapyenv，环境隔离，rpc通讯, 基于zerorpc。

