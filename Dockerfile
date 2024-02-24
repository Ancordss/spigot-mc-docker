# This Dockerfile builds a Minecraft server image using Eclipse Temurin JDK and Alpine Linux.
# It has two stages: mc-build and mc-run.
# In the mc-build stage, it downloads the BuildTools.jar and builds the specified Minecraft version.
# In the mc-run stage, it sets up the Minecraft server with the specified configuration and entrypoint script.

# Build stage
FROM eclipse-temurin:21-jdk-alpine as mc-build

ARG FILENAME
ARG MC_VERSION

ENV FILENAME=$FILENAME

RUN apk update && apk upgrade && apk add wget git

WORKDIR /build
RUN wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar \
    && java -jar BuildTools.jar --rev ${MC_VERSION} --final-name ${FILENAME} && echo "done"

# Run stage
FROM eclipse-temurin:21-jre-alpine as mc-run

WORKDIR /minecraft

EXPOSE 25565

ARG FILENAME
ARG MIN_RAM
ARG MAX_RAM

ENV MIN_RAM=$MIN_RAM \
    MAX_RAM=$MAX_RAM \
    FILENAME=$FILENAME

VOLUME /world
VOLUME /plugins

COPY --from=mc-build /build/${FILENAME} .
COPY entrypoint.sh .
COPY ./config/server.properties .

RUN apk update && apk upgrade && \
    echo "eula=true" > eula.txt && \
    chmod +x ./entrypoint.sh && \
    rm -rf /var/cache/apk/* && \
    sed -ie "s/online-mode=.*/online-mode=${ONLINE_MODE:-false}/" server.properties

ENTRYPOINT ["sh", "entrypoint.sh"]