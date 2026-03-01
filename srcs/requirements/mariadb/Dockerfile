FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y mariadb-server mariadb-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Replace server config (bind on 0.0.0.0 for docker network)
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy entrypoint script
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

# Ensure mysql owns the datadir
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
