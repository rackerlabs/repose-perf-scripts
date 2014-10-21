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



echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>

<system-model xmlns=\"http://docs.rackspacecloud.com/repose/system-model/v2.0\">
  <repose-cluster id=\"repose\">
    <nodes>
      <node id=\"repose_node1\" hostname=\""$1"\" http-port=\"8080\"/>
      <node id=\"repose_node2\" hostname=\""$2"\" http-port=\"8080\"/>
    </nodes>
    <filters>
      <filter name=\"rate-limiting\" />
    </filters>
    <destinations>
      <endpoint id=\"open_repose\" protocol=\"http\" hostname=\"localhost\" root-path=\"/\" port=\"8181\" default=\"true\"/>
    </destinations>
  </repose-cluster>
</system-model>
" > /etc/repose/system-model.cfg.xml 


sed -i.bak 's/MINUTE/SECOND/g' /etc/repose/rate-limiting.cfg.xml
sed -i.bak 's/1000/2000/g' /etc/repose/rate-limiting.cfg.xml
sed -i.bak 's/10/1000/g' /etc/repose/rate-limiting.cfg.xml

sed -i.bak 's/false/true/g' /etc/repose/dist-datastore.cfg.xml
sed -i.bak '/allow host=/d' /etc/repose/dist-datastore.cfg.xml


sed -i.bak "s/-jar $REPOSE_JAR -c $CONFIG_DIRECTORY/-verbose:gc -Xloggc:\/tmp\/gc.log ${*:3} -jar $REPOSE_JAR -c $CONFIG_DIRECTORY/" /etc/init.d/repose-valve

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
