FROM registry.gitlab.com/tozd/docker/nginx:ubuntu-bionic

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

# We install recommended Sympa packages manually otherwise Sympa installation fails.
RUN apt-get update -q -q && \
 apt-get --yes --force-yes --no-install-recommends install nullmailer rsyslog && \
 apt-get --yes --force-yes install openssh-server postgresql-client-10 && \
 apt-get --yes --force-yes --no-install-recommends sympa && \
 apt-get --yes --force-yes install libglib2.0-data shared-mime-info libio-socket-ip-perl \
  libio-socket-inet6-perl krb5-locales libmime-types-perl libsasl2-modules libhtml-form-perl \
  libhttp-daemon-perl libxml-sax-expat-perl xml-core libfile-nfslock-perl libsoap-lite-perl \
  libcrypt-ciphersaber-perl libmail-dkim-perl && \
 mkdir -p /var/run/sympa && \
 chown sympa:sympa /var/run/sympa && \
 chsh --shell /bin/sh sympa && \
 sed -i 's/sympa\.log/sympa\/sympa.log/' /etc/rsyslog.d/sympa.conf && \
 apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm

COPY ./patches /patches

RUN apt-get update -q -q && \
 apt-get --yes --force-yes install patch && \
 for patch in /patches/*; do patch --directory=/ --prefix=/patches/ -p0 --force "--input=/$patch" || exit 1; done && \
 rm -rf /patches && \
 apt-get --yes --force-yes --autoremove purge patch && \
 rm -rf /usr/lib/sympa/locale/en_US /usr/lib/sympa/locale/en && \
 apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm

COPY ./etc /etc
