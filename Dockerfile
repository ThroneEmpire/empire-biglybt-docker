FROM eclipse-temurin:25-jdk

# Added tmux to your existing dependencies
RUN apt-get update && apt-get install -y wget ca-certificates tar unzip net-tools tmux && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/biglybt /config /downloads
WORKDIR /opt/biglybt

COPY entrypoint.sh /entrypoint.sh
COPY port-watcher.sh /port-watcher.sh
RUN chmod +x /entrypoint.sh /port-watcher.sh

EXPOSE 9091 49000/tcp 49000/udp
VOLUME ["/config", "/downloads"]

ENTRYPOINT ["/entrypoint.sh"]
