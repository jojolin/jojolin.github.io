---
layout: post
title: "github-pages搭建个人博客"
date: 2016-09-19 15:54:25 +0800
categories: note github-pages
---

博客终于落地完成，支持本地测试，github上，个人服务器上保持同步更新。
写此文: 1，备忘，2，给需要的朋友提供帮助，3，测试整套博客发布流程。

## 在github上申请[github-pages](https://help.github.com/categories/customizing-github-pages/)

## 本地搭建[jekyll](https://jekyllrb.com/)测试环境。
> - 搭建过程（参照"搭建docker运行环境"）
> - 选择一个模版（个人选择这个模版，因为简单，速度，手机自适应）

## 搭建docker运行环境（个人服务器用，可选）
> - 在debian(jessie)上构建，直接将github-pages项目映射到/root/blog下运行
> - 下面是Dockerfile的一部分（注释是新添加上去的，Dockerfile是一个好东西，
可以让你重新构造整个过程，并清楚地知道所有的依赖和坑)

``` Dockerfile
FROM debian:jessie
MAINTAINER Jianzhou Lin <my@email.com>

ENV VERSION 1.0.0

ENV UPDATE_TIME 2016-09-19 12

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak 
# 用阿里的源
COPY jessie-aliyun-sources.list /etc/apt/sources.list
RUN apt-get update

# {-- 这里开始安装需要的组件。

RUN apt-get install -y --no-install-recommends build-essential

RUN apt-get install -y --no-install-recommends \
    ruby \
    ruby-dev \
    zlib1g-dev \
    nodejs

# 这里更换国内的源
RUN gem sources -a https://gems.ruby-china.org/ -r https://rubygems.org/
# 加--force选项防止一个listen组件的冲突
RUN gem install --force --no-rdoc --no-ri jekyll bundler
COPY ./Gemfile /Gemfile
RUN bundle install --gemfile=/Gemfile

# --} 到此安装完毕。

# RUN apt-get install -y vim
RUN apt-get clean && rm -rf /var/lib/apt/lists

VOLUME ["/root/blog"]
WORKDIR /root/blog
CMD ["bundle", "exec", "jekyll serve -H 0.0.0.0 -P 8080"]
```

## issue
> - ubuntu14.04(ruby2.0)上的安装问题
>   - bundle版本问题，`sudo apt-get install ruby2.0` 系统默认的是1.9.1, 需：
>     - `sudo apt-get install ruby1.9.1-dev ruby2.0-dev`
>     - 查看版本`ruby --version`，版本若不对需修改软连接到`/usr/bin/ruby2.0`
> - jessie(ruby2.1)上无此问题
