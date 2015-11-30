Image providing [Sympa](https://www.sympa.org/) mailing list service.

You should make sure you mount spool and data volumes (`/var/spool/sympa`, `/var/spool/nullmailer`,
and `/var/lib/sympa`) so that you do not lose e-mails and mailing lists data when you are
recreating a container. If volumes are empty, image will initialize them at the first startup.

The intended use of this image is that it is extended (see [cloyne/sympa](https://github.com/cloyne/docker-sympa)
for an example) with customization for your installation, and used together with
[tozd/postfix](https://github.com/tozd/docker-postfix) for receiving and sending e-mails
(see [cloyne/postfix](https://github.com/cloyne/docker-postfix) for an example how to integrate
them together). It is configured to be used with [tozd/postgresql](https://github.com/tozd/docker-postgresql)
PostgreSQL database, by default, running in a contained named `pgsql`. You can link containers together
or use [tozd/hosts](https://github.com/tozd/docker-hosts).
