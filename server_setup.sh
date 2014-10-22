#!/bin/bash

OS=$(lsb_release -si)
if [[ "$OS" == 'Debian' ]]; then
	wget -O - http://repo.openrepose.org/debian/pubkey.gpg | sudo apt-key add -
	echo "deb http://repo.openrepose.org/debian stable main" > /etc/apt/sources.list.d/openrepose.list
	sudo apt-get update
	sudo apt-get install repose-valve repose-filter-bundle repose-extensions-filter-bundle -y

	apt-get install lsof vim -y

	curl -sL https://deb.nodesource.com/setup | bash -
	apt-get install nodejs build-essential -y 

elif [[ "$OS" == 'CentOS' ]]; then
	sudo wget -O /etc/yum.repos.d/openrepose.repo http://repo.openrepose.org/el/openrepose.repo
	sudo yum install repose-valve repose-filters repose-extension-filters  

	yum install -y lsof vim	

	curl -sL https://rpm.nodesource.com/setup | bash -
	yum install -y nodejs
	yum install -y gcc-c++ make
fi

npm install express
npm install sleep
npm install libxmljs
npm install date-utils

echo "
var sleep = require('sleep');
var express = require('express');
var app = express();
app.use (function(req, res, next) {
    var data='';
    req.setEncoding('utf8');
    req.on('data', function(chunk) {
       data += chunk;
    });

    req.on('end', function() {
        req.body = data;
        next();
    });
});

app.get('/*', function(req, res){
  res.send(200,'hello world');
});

app.put('/*', function(req,res){
  res.set('content-type', 'application/atom+xml');
  res.set('x-pp-user', 'user1');
  res.send(201,'<remove-me>test</remove-me>Stuff</a>');
});

app.post('/*', function(req, res){
  res.set('content-type', 'application/atom+xml');
  res.set('x-pp-user', 'user1');
  res.send(201,'foobar'); 

});
app.listen(8181);
" > ~/mock.js

node mock.js start &

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
