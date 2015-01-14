#
FROM muccg/base:ubuntu14.04
MAINTAINER ccg <ccgdevops@googlegroups.com>

ENV DEBIAN_FRONTEND noninteractive

# Project specific deps
RUN apt-get update && apt-get install -y \
  libpcre3 \
  libpcre3-dev \
  libpq-dev \
  libssl-dev \
  wget

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN env --unset=DEBIAN_FRONTEND

# create user so we can drop priviliges for entrypoint
RUN addgroup --gid 1000 ccg-user
RUN adduser --disabled-password --home /data --no-create-home --system -q --uid 1000 --ingroup ccg-user ccg-user
RUN mkdir /data && chown ccg-user:ccg-user /data


WORKDIR /app
RUN rm -rf allegrograph

COPY agraph-4.14.1-linuxamd64.64.tar.gz /tmp/
COPY agraph.cfg /tmp/
WORKDIR /tmp
RUN \
    wget agraph-4.14.1-linuxamd64.64.tar.gz && \
    tar zxvf agraph-4.14.1-linuxamd64.64.tar.gz && \
    cd agraph-4.14.1 && \
    ./install-agraph /app/allegrograph --non-interactive --runas-user ccg-user --super-password xxx  && \
    mkdir /app/allegrograph/etc && \
    cp /tmp/agraph.cfg /app/allegrograph/etc/agraph.cfg && \
    chown -R ccg-user:ccg-user /app 


EXPOSE 10035 
VOLUME ["/app", "/data"]

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Drop privileges, set home for ccg-user
USER ccg-user
ENV HOME /data
WORKDIR /data

# entrypoint shell script that by default starts allegrograph
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["allegrograph_startup"]
