FROM cloyne/nginx:ubuntu-bionic

ENV FCGI_HOST 127.0.0.1
ENV FCGI_PORT 9000
ENV ADMINADDR admin@example.com
ENV REMOTES mail.example.com

VOLUME /var/log/sympa
VOLUME /etc/sympa/includes
VOLUME /etc/sympa/shared
VOLUME /var/spool/sympa
VOLUME /var/lib/sympa
VOLUME /var/spool/nullmailer

# We additionally install recommended Sympa packages which are libraries.

RUN apt-get update -q -q && \
 apt-get install nullmailer rsyslog locales --no-install-recommends --yes && \
 apt-get install openssh-server --yes && \
 echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
 dpkg-reconfigure locales && \
 apt-get install sympa --no-install-recommends --yes && \
 apt-get install libglib2.0-data shared-mime-info libio-socket-ip-perl libio-socket-inet6-perl krb5-locales libmime-types-perl libsasl2-modules libhtml-form-perl libhttp-daemon-perl libxml-sax-expat-perl xml-core libfile-nfslock-perl libsoap-lite-perl libcrypt-ciphersaber-perl libmail-dkim-perl --yes && \
 mkdir -p /var/run/sympa && \
 chown sympa:sympa /var/run/sympa && \
 chsh --shell /bin/sh sympa && \
 sed -i 's/sympa\.log/sympa\/sympa.log/' /etc/rsyslog.d/sympa.conf && \
 mkdir -m 700 /var/spool/sympa.orig /var/spool/nullmailer.orig /var/lib/sympa.orig && \
 (mv /var/spool/sympa/* /var/spool/sympa.orig/ || true) && \
 (mv /var/spool/nullmailer/* /var/spool/nullmailer.orig/ || true) && \
 (mv /var/lib/sympa/* /var/lib/sympa.orig/ || true) && \
 (cp -R /var/lib/sympa.orig/static_content /var/lib/sympa/static_content || true) && \
 apt-get install postgresql-client-10 --yes

COPY ./patches patches

RUN \
 apt-get install patch --yes && \
 for patch in patches/*; do patch -p0 -d/ --force --input="$patch" || exit 1; done && \
 rm -rf patches && \
 apt-get purge patch --yes && \
 apt-get autoremove --yes && \
 rm -rf /usr/lib/sympa/locale/en_US /usr/lib/sympa/locale/en

COPY ./etc /etc
