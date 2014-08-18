#/bin/bash -e

mkdir -p /srv/var/log/sympa
mkdir -p /srv/sympa/spool
mkdir -p /srv/sympa/nullmailer
mkdir -p /srv/sympa/data

# /srv/sympa/etc/includes/database contains a password for sympa user with
# permissions over sympa PostgreSQL database at pgsql.postgresql.server2.docker
# /srv/sympa/etc/includes/cookie contains crypto cookie string secret

# You can create the database with:
# createuser -h pgsql.postgresql.server2.docker -PE -DRS -U postgres -W sympa
# createdb -h pgsql.postgresql.server2.docker -U postgres -W -O sympa sympa

docker run -d --name sympa -h sympa.sympa.server2.docker -v /srv/var/log/sympa:/var/log/sympa -v /srv/sympa/etc/includes:/etc/sympa/includes -v /srv/sympa/spool:/var/spool/sympa -v /srv/sympa/nullmailer:/var/spool/nullmailer -v /srv/sympa/data:/var/lib/sympa cloyne/sympa
