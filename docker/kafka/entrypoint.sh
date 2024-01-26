#!/bin/bash

. /opt/bitnami/scripts/libfile.sh
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/libkafka.sh

config_done=/opt/bitnami/kafka/config/kraft/config_done

# KAFKA_CONF_FILE is from /opt/bitnami/scripts/kafka-env.sh
export KAFKA_CONF_FILE=/opt/bitnami/kafka/config/kraft/server.properties

if [[ ! -f $config_done ]]; then
  echo "Will edit config"
  # altering config (uses KAFKA_CONF_FILE)
  kafka_configure_from_environment_variables

  touch $config_done
else
  echo "config is already edited, skipping"
fi


export PATH=${PATH}:/opt/bitnami/kafka/bin

format_done=/var/lib/kafka-data/format_done
if [[ ! -f $format_done ]]; then
  echo "Will format kafka-storage for KRaft"

  # KRaft required step: Format the storage directory with a new cluster ID
  kafka-storage.sh format --ignore-formatted -t $(kafka-storage.sh random-uuid) -c $KAFKA_CONF_FILE

  touch $format_done
else
  echo "kafka-storage is already formatted, skipping"
fi

echo "Starting non-original run script"
exec kafka-server-start.sh $KAFKA_CONF_FILE