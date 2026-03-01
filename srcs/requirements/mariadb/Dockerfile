FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y mariadb-server mariadb-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh && \
    mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
