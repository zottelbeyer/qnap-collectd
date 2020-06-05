# qnap-collectd

this multi-arch collectd container contains collectd with snmp support and the QNAP NAS-MIB.
drop your config in collectd.conf.d.

For details on intended usage check out [QNAP-collectdinfluxdbgrafana](https://github.com/zottelbeyer/QNAP-collectdinfluxdbgrafana)

sample docker-compose.yml:

```
version: '3'

services:  
  collectd:
    container_name: qnap-collectd
    image: zottelbeyer/qnap-collectd:latest
    privileged: true
    network_mode: host
    volumes:
      - /:/rootfs/:ro
      - ./qnap-collectd/collectd.conf.d:/etc/collectd/collectd.conf.d/:ro    

  influxdb:
    container_name: influxdb
    image: influxdb:1.8
    ports:
      - "8086:8086"
      - "25826:25826/udp"
    environment:
      INFLUXDB_USER: ${INFLUXDB_USERNAME}
      INFLUXDB_USER_PASSWORD: ${INFLUXDB_PASSWORD}
      INFLUXDB_DB: ${INFLUXDB_DATABASE}
    volumes:
      - ./influxdb/influxdb.conf:/etc/influxdb/influxdb.conf
      - ./influxdb/types.db:/usr/share/collectd/types.db
      - ./influxdb-data:/var/lib/influxdb      

  grafana:
    container_name: grafana
    image: grafana/grafana:7.0.3
    user: "root"
    environment:
      GF_SECURITY_ADMIN_USER: ${GF_SECURITY_ADMIN_USER}
      GF_SECURITY_ADMIN_PASSWORD: ${GF_SECURITY_ADMIN_PASSWORD}
    ports:
      - "3000:3000"
    volumes:
      - ./grafana/datasource.yaml:/etc/grafana/provisioning/datasources/datasource.yaml
      - ./grafana/dashboard.yaml:/etc/grafana/provisioning/dashboards/dashboard.yaml
      - ./grafana/QNAP-collectd.json:/var/lib/grafana/dashboards/QNAP-collectd.json
      - ./grafana-data:/var/lib/grafana
```


