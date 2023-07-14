# tozd/sympa

<https://gitlab.com/tozd/docker/sympa>

Available as:

- [`tozd/sympa`](https://hub.docker.com/r/tozd/sympa)
- [`registry.gitlab.com/tozd/docker/sympa`](https://gitlab.com/tozd/docker/sympa/container_registry)

## Image inheritance

[`tozd/base`](https://gitlab.com/tozd/docker/base) ← [`tozd/dinit`](https://gitlab.com/tozd/docker/dinit) ← [`tozd/nginx`](https://gitlab.com/tozd/docker/nginx) ← [`tozd/nginx-mailer`](https://gitlab.com/tozd/docker/nginx-mailer) ← `tozd/sympa`

## Tags

- `latest`: Sympa 6.2.66

## Volumes

- `/var/log/sympa`: Log files. Logs are **not** rotated.
- `/etc/sympa/includes`: Secrets used by Sympa. It should contain two files:
  - `database`: A password for `sympa` user with permissions over `sympa` PostgreSQL database at (by default) `pgsql` container.
  - `cookie`: A randomly generated string used for cookie string secret.
- `/etc/sympa/shared`: A volume shared with a Postfix container to provide necessary SSH keys for communication between containers.
- `/var/spool/sympa`: Persist this volume to not lose state.
- `/var/lib/sympa`: Persist this volume to not lose state.

## Description

Docker image providing [Sympa](https://www.sympa.org/) mailing list service.
When the container runs Sympa is available at `/sympa/` and `/lists/` URLs.

You should make sure you mount spool and data volumes (`/var/spool/sympa` and `/var/lib/sympa` from this image
and `/var/spool/nullmailer` from `tozd/nginx-mailer`) so that you do not lose e-mails and mailing lists data
when you are recreating a container.

The intended use of this image is that it is extended (see [cloyne/sympa](https://github.com/cloyne/docker-sympa)
for an example) with customizations for your installation, and used together with
[tozd/postfix](https://gitlab.com/tozd/docker/postfix) for receiving and sending e-mails.
`tozd/postfix` container should be configured to use SSH to deliver e-mails to `tozd/sympa`
and use `REMOTES` environment variable to specify the container (i.e., `tozd/postfix`)
or server used for sending e-mails.
See [cloyne/postfix](https://github.com/cloyne/docker-postfix) for an example how to integrate
images together.

The image is by default configured to be used with [tozd/postgresql](https://gitlab.com/tozd/docker/postgresql)
PostgreSQL database, running in a container named `pgsql`.

**The image contains only example values and cannot run without extending (or mounting necessary files into it).**

You should provide two volumes, `/etc/sympa/includes` and `/etc/sympa/shared`.

When extending the image you should override files in the `/etc/sympa/conf.d` directory
with ones containing your values. Moreover you probably want to define your own Sympa robot.

To create a database for Sympa, `exec` into your PostgreSQL container and run:

```
$ createuser -U postgres -DRS -PE sympa
$ createdb -U postgres -O sympa sympa
```

You have to initialize afterwards the database. Run from inside your Sympa container:

```
$ psql -h pgsql -U sympa -W -f /usr/share/sympa/bin/create_db.Pg
```

## GitHub mirror

There is also a [read-only GitHub mirror available](https://github.com/tozd/docker-sympa),
if you need to fork the project there.
