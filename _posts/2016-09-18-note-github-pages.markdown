---
layout: post
title: "github pages"
date: 2016-09-18 11:54:25 +0800
categories: note github-pages
---
note of building github pages (not finished!)

## intall requirements
> - install ruby and jekyll [(jekyllrb)](https://jekyllrb.com/)
> - `sudo apt-get install build-essential libopenssl-ruby ruby2.0-dev`
> - `gem install jekyll bundler`
> - `sudo apt-get install nodejs`
> - `bundle install` to install github-pages
> - `bundle exec jekyll new . --force` to create template
> - `bundle exec jekyll serve -H 0.0.0.0` to run

## add template
> - find a jekyll's template (I prefer this one for simple and speed ^-^)

## issue
> - gem sources --add http://gems.ruby-china.org/ --remove https://rubygems.org/
> - the bundle(in /usr/local/bin/) version is 1.9.1 when installed with `sudo apt-get install`
