cd opt/kafka 
zookeeper-server-start.sh config/zookeeper.properties # start zookeeper
kafka-server-start.sh config/server.properties # start kafka
kafka-topics.sh --create --partitions 1 --replication-factor 1 --topic sync-mem-block --bootstrap-server localhost:9092 # create topic
tail -F anything