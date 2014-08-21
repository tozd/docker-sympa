FROM cloyne/nginx

MAINTAINER Mitar <mitar.docker@tnode.com>

ENV FCGI_HOST 127.0.0.1
ENV FCGI_PORT 9000

COPY ./etc/apt /etc/apt

# We additionally install recommended Sympa packages which are libraries
RUN apt-get update -q -q && \
 apt-get install nullmailer rsyslog locales --no-install-recommends --yes --force-yes && \
 apt-get install openssh-server --yes --force-yes && \
 echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
 dpkg-reconfigure locales && \
 apt-get install -t wheezy-backports sympa --no-install-recommends --yes --force-yes && \
 apt-get install libglib2.0-data shared-mime-info libio-socket-ip-perl libio-socket-inet6-perl krb5-locales libmime-types-perl libsasl2-modules libhtml-form-perl libhttp-daemon-perl libxml-sax-expat-perl xml-core libfile-nfslock-perl libsoap-lite-perl libcrypt-ciphersaber-perl libmail-dkim-perl --yes --force-yes && \
 mkdir -p /var/run/sympa && \
 chown sympa:sympa /var/run/sympa && \
 chsh --shell /bin/sh sympa && \
 sed -i 's/sympa\.log/sympa\/sympa.log/' /etc/rsyslog.d/sympa.conf && \
 mkdir -m 700 /var/spool/sympa.orig /var/spool/nullmailer.orig /var/lib/sympa.orig && \
 mv /var/spool/sympa/* /var/spool/sympa.orig/ && \
 mv /var/spool/nullmailer/* /var/spool/nullmailer.orig/ && \
 mv /var/lib/sympa/* /var/lib/sympa.orig/

COPY ./patches patches

RUN \
 apt-get install patch --yes --force-yes && \
 for patch in patches/*; do patch --prefix=./patches/ -p0 --force "--input=$patch" || exit 1; done && \
 rm -rf patches && \
 apt-get purge patch --yes --force-yes

COPY ./etc /etc
