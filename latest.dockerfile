FROM registry.gitlab.com/tozd/docker/nginx-mailer:ubuntu-jammy

VOLUME /var/log/sympa
VOLUME /etc/sympa/includes
VOLUME /etc/sympa/shared
VOLUME /var/spool/sympa
VOLUME /var/lib/sympa

# We install recommended Sympa packages manually to control what gets installed.
# We first install dbconfig-sqlite3  so that during instalation it initializes a database into a file.
# Later on we replace it with dbconfig-pgsql.
RUN apt-get update -q -q && \
  touch /etc/aliases && \
  echo sympa sympa/listmaster string "listmaster@example.com" | debconf-set-selections && \
  apt-get --yes --force-yes --no-install-recommends install rsyslog openssh-server dbconfig-sqlite3 sympa && \
  apt-get --yes --force-yes install libclass-c3-xs-perl libdevel-lexalias-perl \
  libfcgi-bin libintl-xs-perl javascript-common libjs-bootstrap libjson-xs-perl \
  libmime-types-perl libdigest-bubblebabble-perl libnet-dns-sec-perl libnet-libidn-perl \
  libperl4-corelibs-perl libgssapi-perl libauthen-sasl-perl libpackage-stash-xs-perl \
  libclass-xsaccessor-perl libxmlrpc-lite-perl libref-util-perl libmath-base-convert-perl \
  libtext-soundex-perl libdata-dump-perl libhtml-form-perl libxml-sax-expat-perl \
  libcrypt-ciphersaber-perl && \
  apt-get --yes --force-yes install dbconfig-pgsql && \
  apt-get --yes --force-yes --autoremove purge dbconfig-sqlite3 && \
  rm -rf /var/lib/dbconfig-common/sqlite3/sympa && \
  chsh --shell /bin/sh sympa && \
  sed -i 's/sympa\.log/sympa\/sympa.log/' /etc/rsyslog.d/sympa.conf && \
  rm -f /etc/sympa/cookie /etc/sympa/cookies.history && \
  sed -i '/imklog/s/^/#/' /etc/rsyslog.conf && \
  mkdir -m 700 /var/lib/sympa.orig && \
  mv /var/lib/sympa/* /var/lib/sympa.orig/ && \
  mkdir -m 700 /var/spool/sympa.orig && \
  mv /var/spool/sympa/* /var/spool/sympa.orig/ && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm

COPY ./patches /patches

RUN apt-get update -q -q && \
  apt-get --yes --force-yes install patch && \
  for patch in /patches/*; do patch --directory=/ --prefix=/patches/ -p0 --force "--input=/$patch" || exit 1; done && \
  rm -rf /patches && \
  apt-get --yes --force-yes --autoremove purge patch && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm

COPY ./etc/nginx /etc/nginx
COPY ./etc/service/rsyslog /etc/service/rsyslog
COPY ./etc/service/sshd /etc/service/sshd
COPY ./etc/service/sympa_archived /etc/service/sympa_archived
COPY ./etc/service/sympa_bounced /etc/service/sympa_bounced
COPY ./etc/service/sympa_bulk /etc/service/sympa_bulk
COPY ./etc/service/sympa_msg /etc/service/sympa_msg
COPY ./etc/service/sympa_task_manager /etc/service/sympa_task_manager
COPY ./etc/service/wwsympa /etc/service/wwsympa
COPY ./etc/sympa /etc/sympa
