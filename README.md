##Server Setup:
The server_setup script installs Repose for Debian or CentOS by automatically detecting which OS is running. It also creates and starts a simple mock origin service.

##Load Configs:
The load_configs script loads the configuration files located in the specified [configs folder](https://github.com/rackerlabs/repose-perf-scripts/tree/setup_script/configs/rate-limiting). It also populates the hostnames for the nodes in system-model.cfg.xml. The script replaces {host#} the given hostnames/IP addresses. For example:

./load_configs.sh rate-limiting 123.456.789 123.123.123

Before: 
```
<node id="repose_node1" hostname="{host1}" http-port="8080"/>
<node id="repose_node2" hostname="{host2}" http-port="8080"/>
```

After:
```
<node id="repose_node1" hostname="123.456.789" http-port="8080"/>
<node id="repose_node2" hostname=" 123.123.123" http-port="8080"/>
```
