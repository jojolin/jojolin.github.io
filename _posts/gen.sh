#!/bin/sh
note_name=$1
categories=$2
title=$3

if [[ -z $categories ]]; then
    echo "no categories given, exit"
    exit 1
fi

if [[ -z $note_name ]]; then
    echo "no blog name given, exit"
    exit 1
fi
if [[ -z $title ]];then
    $title=$note_name
    echo "no title given, use note_name"
fi

datefile=`date +%F`
dateblog=`date +"%F %H:%M:%S %z"`
file_name=${datefile}-${note_name}.markdown

if [[ -f $file_name ]]; then 
    echo "file name exists"
    exit 1
fi

echo "gen markdown: "${file_name}
touch ${file_name}
echo "---" >> ${file_name}
echo "layout: post" >> ${file_name}
echo "title: "$title >> ${file_name} 
echo "date: "${dateblog} >> ${file_name}
echo "categories: "${categories} >> ${file_name}
echo "---" >> ${file_name}
vim $file_name
