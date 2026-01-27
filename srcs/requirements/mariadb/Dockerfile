FROM debian:bullseye

RUN apt update && apt install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init_db.sh /usr/local/bin/init_db.sh

ENTRYPOINT ["/usr/local/bin/init_db.sh"]
CMD ["mysqld", "--user=mysql"]
