SELECT star FROM streams
------------------------

https://blog.rockthejvm.com/flink-sql-introduction/

```bash
docker-compose up -d
docker exec -it jobmanager ./bin/sql-client.sh

CREATE DATABASE mydbl;
SHOW DATABASES;
use mydbl;

Ctrl+D

docker exec -it kafka kafka-topics.sh --create   --topic sensor.info   --partitions 1   --config cleanup.policy=compact   --bootstrap-server localhost:9092
docker exec -it kafka kafka-topics.sh --create --topic sensor.readings --partitions 3 --bootstrap-server localhost:9092
docker exec -it kafka kafka-topics.sh --bootstrap-server localhost:9092 --describe

docker exec -it jobmanager ./bin/sql-client.sh

CREATE TABLE readings (
  sensorId STRING,
  reading DOUBLE,
  eventTime_ltz AS TO_TIMESTAMP_LTZ(`timestamp`, 3),
  `ts` TIMESTAMP(3) METADATA FROM 'timestamp',
  `timestamp` BIGINT,
    WATERMARK FOR eventTime_ltz AS eventTime_ltz - INTERVAL '30' SECONDS
) WITH (
  'connector' = 'kafka',
  'topic' = 'sensor.readings',
  'properties.bootstrap.servers' = 'kafka:29092',
  'properties.group.id' = 'group.sensor.readings',
  'format' = 'json',
  'scan.startup.mode' = 'earliest-offset',
  'json.timestamp-format.standard' = 'ISO-8601',
  'json.fail-on-missing-field' = 'false',
  'json.ignore-parse-errors' = 'true'
);
  
DESCRIBE readings;

CREATE TABLE sensors (
  sensorId STRING,
  latitude String,
  longitude String,
  sensorType STRING,
  generation STRING,
  deployed BIGINT
) WITH (
  'connector' = 'kafka',
  'topic' = 'sensor.info',
  'properties.bootstrap.servers' = 'kafka:29092',
  'properties.group.id' = 'group.sensor.info',
  'format' = 'json',
  'scan.startup.mode' = 'earliest-offset',
  'json.timestamp-format.standard' = 'ISO-8601',
  'json.fail-on-missing-field' = 'false',
  'json.ignore-parse-errors' = 'true'
);
  
DESCRIBE sensors;

SHOW TABLES;
```
