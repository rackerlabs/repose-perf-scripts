#!/bin/bash

cp -r configs/$1/* /etc/repose/

for ((i=2;i<=$#;i++))
do
  sed -i.bak "s/{host$(($i-1))}/${!i}/" /etc/repose/system-model.cfg.xml
done

