# tozd/sympa

<https://gitlab.com/tozd/docker/sympa>

Available as:

* [`tozd/sympa`](https://hub.docker.com/r/tozd/sympa)
* [`registry.gitlab.com/tozd/docker/sympa`](https://gitlab.com/tozd/docker/sympa/container_registry)

## Description

Docker image providing [Sympa](https://www.sympa.org/) mailing list service.

You should make sure you mount spool and data volumes (`/var/spool/sympa`, `/var/spool/nullmailer`,
and `/var/lib/sympa`) so that you do not lose e-mails and mailing lists data when you are
recreating a container.

The intended use of this image is that it is extended (see [cloyne/sympa](https://github.com/cloyne/docker-sympa)
for an example) with customizations for your installation, and used together with
[tozd/postfix](https://gitlab.com/tozd/docker.postfix) for receiving and sending e-mails
(see [cloyne/postfix](https://github.com/cloyne/docker-postfix) for an example how to integrate
them together). It is configured to be used with [tozd/postgresql](https://gitlab.com/tozd/docker/postgresql)
PostgreSQL database, by default, running in a container named `pgsql`.
Use `REMOTES` environment variable to specify the container or server used for sending e-mails.

**The image contains only example values and cannot run without extending (or mounting necessary files into it).**

You should provide two volumes, `/etc/sympa/includes` and `/etc/sympa/shared`.

`/etc/sympa/includes` should contain two files:
 * `database` – a password for `sympa` user with permissions over `sympa` PostgreSQL database at (by default) `pgsql` container
 * `cookie` – a randomly generated string used for cookie string secret

`/etc/sympa/shared` is a volume shared with (for example) `cloyne/postfix`
container to provide necessary SSH keys for communication between containers.

When extending the image you should override files in the `/etc/sympa/conf.d` directory
with ones containing your values. Moreover you probably want to define your own Sympa robot.

To create a database for Sympa, `exec` into your PostgreSQL container and run:

```
$ createuser -U postgres -DRS -PE sympa
$ createdb -U postgres -O sympa sympa
```

You might have to initialize afterwards the database. Run from inside your Sympa container:

```
$ psql -h pgsql -U sympa -W -f /usr/share/sympa/bin/create_db.Pg
```
