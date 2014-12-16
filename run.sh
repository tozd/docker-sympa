#!/bin/bash -e

mkdir -p /srv/var/log/sympa
mkdir -p /srv/sympa/etc/includes
mkdir -p /srv/sympa/etc/shared
mkdir -p /srv/sympa/spool
mkdir -p /srv/sympa/nullmailer
mkdir -p /srv/sympa/data

# /srv/sympa/etc/includes/database contains a password for sympa user with
# permissions over sympa PostgreSQL database at pgsql.server2.docker
# /srv/sympa/etc/includes/cookie contains crypto cookie string secret

# You can create the database with:
# createuser -h pgsql.server2.docker -PE -DRS -U postgres -W sympa
# createdb -h pgsql.server2.docker -U postgres -W -O sympa sympa

# You might have to initialize the database with:
# psql -h pgsql.server2.docker -U sympa -W -f /usr/share/sympa/bin/create_db.Pg

docker run -d --restart=always --name sympa --hostname sympa -e SET_REAL_IP_FROM=172.17.0.0/16 -v /srv/var/hosts:/etc/hosts:ro -v /srv/var/log/sympa:/var/log/sympa -v /srv/sympa/etc/includes:/etc/sympa/includes -v /srv/sympa/etc/shared:/etc/sympa/shared -v /srv/sympa/spool:/var/spool/sympa -v /srv/sympa/nullmailer:/var/spool/nullmailer -v /srv/sympa/data:/var/lib/sympa cloyne/sympa
