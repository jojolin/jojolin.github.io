---
layout: post
title: 分布式scrapy框架搭建
date: 2016-09-19 22:53:20 +0800
categories: note program
---
可参考scrapy-redis项目

- 继承以下SpiderBase类即可实现redis最基本分布式，同时支持命令行调试。
- 通过scrapyd以进程方式进行调度。

- spiderbase.py

```
# -*- coding: utf-8 -*-
'''
Package: spiderbase.py
Author: ^-^
-----

'''

import sys
import logging
import scrapy
from scrapy import signals
from scrapy.exceptions import DontCloseSpider

from cmdlinebase import CmdlineBase
from redisbase import RedisBase

class SpiderBase(scrapy.Spider):
    name = 'xx'
    project = 'xx'

    def __init__(self, *args, **kwargs):
        '''
        Initialize spider and get the url.
        '''
        super(SpiderBase, self).__init__()
        self.crawl_item = None
        # set source instance
        if kwargs.get('debug-item', None):
            self.src_ins = CmdlineBase(*args, **kwargs)
            print '***** entering debug-mode'
        else:
            self.src_ins = RedisBase(*args,
                                     spider_project=self.project,
                                     spider_name=self.name)

    def close(self, reason):
        if not reason == 'finished':
            logging.info('%s close, reason: %s' % (self.name, reason))
            self.push_back_item(self.crawl_item)

    def parse_failure(self, failure):
        url = failure.request.url
        logging.info('failed request url: %(url)s, type:%(type)s, value:%(value)s',
                     {'url':url, 'type': failure.type, 'value': failure.value})
        logging.error('parse_failure, request meta:%s' % failure.request.meta)
        if failure.type is scrapy.exceptions.IgnoreRequest:
            if failure.value == 'timeout':
                self.discard_item(self.crawl_item)
            elif failure.value == 'banned':
                self.push_back_item(self.crawl_item)

    def discard_item(self, crawl_item):
        if crawl_item:
            logging.info('discard crawl_item to redis: %s' % self.crawl_item)
            self.src_ins.discard_item(self.crawl_item)

    def push_back_item(self, crawl_item):
        if crawl_item:
            logging.info('push back crawl_item to redis: %s' % self.crawl_item)
            self.src_ins.pusl_back_item(self.crawl_item)

    def _set_crawler(self, crawler):
        '''
        This method overrite Spider's _set_crawler to setup redis.
        called after the __init__.
        '''
        super(SpiderBase, self)._set_crawler(crawler)
        self.crawler.signals.connect(self.spider_idle, signal=signals.spider_idle)
        self.setup_log()
        self.src_ins.setup(self.crawler.settings)

    def setup_log(self):
        "when in debug-mode, log to file and print on screen"
        run_mode = self.crawler.settings.get('RUN_MODE', 'release')
        log_level = self.crawler.settings.get('LOG_LEVEL', 'INFO')
        if run_mode.find('debug') > -1 or run_mode.find('DEBUG') > -1:
            log_file = '/tmp/spider-%s.log' % self.name
            fh = logging.FileHandler(log_file, mode='w')
            fh.setLevel(getattr(logging, log_level))
            logging.root.addHandler(fh)
            logging.info('logging in log file: %s' % log_file)

    def spider_idle(self):
        self.schedule_next_request()
        raise DontCloseSpider

    def schedule_next_request(self):
        """Schedules a request if available"""
        req = self.next_request()
        if req:
            self.crawler.engine.crawl(req, spider=self)

    def next_request(self):
        '''
        get next request.
        overwrite super's method to support multiple parsers
        '''
        self.crawl_item = self.src_ins.next_crawl_item()
        if self.crawl_item:
            logging.info('read crawl_item: "%s"' % self.crawl_item)
            url, meta = self.src_ins.get_url_meta_from_crawl_item(self.crawl_item)
            return scrapy.Request(url=url,
                                  dont_filter=True,
                                  callback=self.parse_items,
                                  errback=self.parse_failure)
        else:
            return None

    def parse_items(self, response):
        "overrite by child class."
        raise NotImplementedError
```

- redisbase.py: redis基类

```
# -*- coding: utf-8 -*-
'''
redis source.
'''
import logging
import redis

class RedisBase(object):

    def __init__(self, *args, **kwargs):
        '''
        Initialize spider and get the url.
        '''
        super(RedisBase, self).__init__()

        self.sp_project = kwargs.pop('spider_project', '')
        self.sp_name = kwargs.pop('spider_name', '')
        self.redis_host = 'localhost'
        self.redis_port = 6379
        self.redis_pwd =''
        self.redis_key = ''
        self.url_seprator = '@@'
        self.server = None

    def push_back_item(self, crawl_item):
        self.server.lpush(self.redis_key, self.crawl_item)

    def discard_item(self, crawl_item):
        # TODO: maybe log to somewhere
        pass

    def push_back_item(self, crawl_item):
        # TODO: maybe log to somewhere
        pass

    def setup(self, settings):
        self.url_seprator = settings.get('URL_SEPRATOR', self.url_seprator)
        self.redis_host  = settings.get('REDIS_HOST', self.redis_host)
        self.redis_port  = settings.getint('REDIS_PORT', self.redis_port)
        self.redis_pwd =  settings.get('REDIS_PASSWORD', None)
        self.server = redis.Redis(host=self.redis_host,
                                  port=self.redis_port,
                                  password=self.redis_pwd)
        self.redis_key = self.get_redis_key(self.sp_project, self.sp_name)
        logging.info('Read crawl item from redis "(%s:%s)%s"' \
                     % (self.redis_host, self.redis_port, self.redis_key))

    def next_crawl_item(self):
        '''
        get next request from redis.
        '''
        return self.server.rpop(self.redis_key)

    def get_url_meta_from_crawl_item(self, crawl_item):
        url, _ = crawl_item.split(self.url_seprator)
        return url, {}

    def get_redis_key(self, project, name):
        return '%s:%s:crawl-items' % (project, name)
```

- cmdlinebase.py: 命令行基类

```
# -*- coding: utf-8 -*-
'''
Package: debugbase.py
Author: ^-^
-----
command line source.
'''
import Queue

class CmdlineBase(object):

    def __init__(self, *args, **kwargs):
        self.debug_items = Queue.Queue()
        self.debug_items.put(kwargs.get('debug-item'))

    def next_crawl_item(self):
        try:
            return self.debug_items.get(False)
        except Queue.Empty:
            return None

    def get_url_meta_from_crawl_item(self, crawl_item):
        url, ct = crawl_item.split('@@')
        return url, {}

    def discard_item(self, crawl_item):
        pass

    def push_back_item(self, crawl_item):
        pass

    def setup(self, settings):
        pass
```
