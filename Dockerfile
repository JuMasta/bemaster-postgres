# syntax=docker/dockerfile:1
FROM ubuntu:20.04
ENV TZ=Europe/Moscow
ARG user
ARG password
ARG db
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update\
    && apt-get install -y wget\
    && apt-get install -y gnupg

RUN echo "deb http://apt.postgresql.org/pub/repos/apt focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update\
    && apt-get install -y postgresql-12
USER postgres
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER ${user} WITH SUPERUSER PASSWORD '${password}' ;" &&\
    createdb -O ${user} ${db}

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/12/main/pg_hba.conf
RUN sed -i 's/local   all             all                                     peer/local   all             $user{}                                     md5/g'  /etc/postgresql/12/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/12/main/postgresql.conf
EXPOSE 5432
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
CMD ["/usr/lib/postgresql/12/bin/postgres", "-D", "/var/lib/postgresql/12/main", "-c", "config_file=/etc/postgresql/12/main/postgresql.conf"]
