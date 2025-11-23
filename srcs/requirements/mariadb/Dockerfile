FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/

COPY tools/init.sh /docker-entrypoint-initdb.d/

EXPOSE 3306

CMD ["mysqld"]