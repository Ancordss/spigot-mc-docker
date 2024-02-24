#!/bin/bash


sed -ie "s/online-mode=.*/online-mode=${ONLINE_MODE:-false}/" server.properties
echo "online-mode: ${ONLINE_MODE:-false}"
sed -ie "s/server-port=.*/server-port=${PORT:-25565}/" server.properties
echo "server-port: ${PORT:-25565}"



java -Xms${MIN_RAM} -Xmx${MAX_RAM} -XX:+UseG1GC -jar ${FILENAME} nogui