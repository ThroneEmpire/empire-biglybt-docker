FROM eclipse-temurin:25-jdk

RUN apt-get update && apt-get install -y wget ca-certificates tar unzip net-tools && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/biglybt /config /downloads
WORKDIR /opt/biglybt

RUN wget -O /tmp/biglybt.tar.gz https://files.biglybt.com/installer/BiglyBT_unix.tar.gz \
    && tar -xzf /tmp/biglybt.tar.gz -C /opt/biglybt --strip-components=1 \
    && rm -f /tmp/biglybt.tar.gz

ENV BIGLY_JAVA_OPTS="--add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9091 49000/tcp 49000/udp
VOLUME ["/config", "/downloads"]

ENTRYPOINT ["/entrypoint.sh"]
