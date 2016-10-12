---
layout: post
title: 快速部署开发环境
date: 2016-09-19 22:22:25 +0800
categories: note shift-dev-env
---
随身携带的开发环境(python为主)
相关配置以个人喜好为主，故不列出。

## 最基本
- install-basic.sh

```
#!/bin/sh

mv /etc/apt/sources.list /etc/apt/sources.list.bak
cat ./ubuntu14.04-aliyun-sources.list > /etc/apt/sources.list
apt-get update
apt-get install -y --no-install-recommends \
    openssh-server \
    vim \
    emacs \
    tmux \
    git \
    python-dev \
    python-pip \
    zsh

# link sh to bash
cp /bin/bash /bin/bash.bak
rm /bin/sh
ln -s /bin/bash /bin/sh

pip install -U pip
pip install supervisor

# set up for emacs-python-dev en
pip install jedi epc
pip install ipython
pip install virtualenv virtualenvwrapper
```

## 各种用户配置
- install-user.sh

```
#!/bin/sh

usr=$1
usr_home=""
if [[ $usr == "" ]]; then
    echo "no user given"
    exit 1
elif [[ $usr == "root" ]]; then
    usr_home=/root
else
    usr_home=/home/$usr
fi

if [[ ! -w $usr_home/.bashrc ]]; then
    touch $usr_home/.bashrc
fi

cp ./{.gitconfig,.jshrc,.tmux.conf} $usr_home/
touch $usr_home/.localrc
echo "source ~/.localrc" >> $usr_home/.jshrc
echo "source ~/.jshrc" >> $usr_home/.bashrc

source ./install-vim-conf.sh $usr_home
source ./install-emacs-conf.sh $usr_home
source ./install-oh-my-zsh.sh $usr_home

rm -rf .vim_runtime/
rm -rf .emacs.d/
rm -rf .oh-my-zsh/

```

- install-oh-my-zsh.sh

```
#!/bin/sh

usr_home=$1

if [[ -d $usr_home ]]; then
    if [[ -f $usr_home/.zshrc ]]; then
        cp $usr_home/.zshrc $usr_home/.zshrc.bak
    fi
    tar -xf .oh-my-zsh.tar.gz
    cp -r ./{.zshrc,.oh-my-zsh} $usr_home/
    echo "source ~/.jshrc" >> $usr_home/.zshrc
    cp ./robbyrussell.zsh-theme $usr_home/.oh-my-zsh/themes/robbyrussell.zsh-theme
    echo "install oh-my-zsh config in" $usr_home
else
    echo "no usr_home, install vim config failed"
    exit 1
fi

# install from github
# sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

- install-emacs-conf.sh

```
#!/bin/sh

usr_home=$1

if [[ -d $usr_home ]]; then
    tar -xf .emacs.d.tar.gz 
    cp -r ./.emacs.d $usr_home/
    echo "install emacs config in" $usr_home
else
    echo "invalid usr_home, install emacs config failed"
    exit 1
fi

```

- install-vim-conf.sh

```
#!/bin/sh

usr_home=$1
if [[ -d $usr_home ]]; then
    tar -xf .vim_runtime.tar.gz
    cp -r ./{.vimrc,.vim_runtime} $usr_home/
    echo "install vim config in" $usr_home
else
    echo "no usr_home, install vim config failed"
    exit 1
fi

```

- emacs.d-tar.sh

```
#!/bin/bash
tar -zcf .emacs.d.tar.gz -X .emacs.d-tar.ex .emacs.d/
```

- vim_runtime.sh

```
#!/bin/bash
tar -zcf .vim_runtime.tar.gz -X .vim_runtime-tar.ex .vim_runtime/
```

- oh-my-zsh-tar.sh

```
#!/bin/bash
tar -zcf .oh-my-zsh.tar.gz -X .oh-my-zsh-tar.ex .oh-my-zsh/
```

## 开发相关 
- install-networkenv.sh

```
#!/bin/sh

pip install \
    flask \
    flask-assets \
    flask-bcrypt \
    flask-cache \
    flask-debugtoolbar \
    flask-login \
    flask-migrate \
    flask-script \
    flask-sqlalchemy \
    flask-wtf \
    gunicorn \
    pymysql \
    redis \
    requests \
    uwsgi \
    uwsgitop
```

- install-scrapy-base.sh

```
#!/bin/sh
# run as root

apt-get install -y --no-install-recommends \
    python-pip \
    python-dev \
    build-essential \
    libxml2 \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libffi-dev \
    libssl-dev

```

- install-scrapyenv.sh

```
#!/bin/sh

pip install \
    w3lib \
    scrapy \
    scrapyd \
    redis \
    pymysql \
    requests
```
