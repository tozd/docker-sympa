## Ready to use sympa docker image


Build the image:
```
git clone -b 6.2.38 https://github.com/OlivierGuilloux/docker-sympa
cd docker-sympa
docker build -t docker-sympa:6.2.38 .
```

Add your specifics (cf. sample/):
```
FROM docker-sympa-ws:6.2.38

# Update the configuration
COPY ./etc/sympa /etc/sympa
RUN chown sympa.sympa -R /etc/sympa

# Copy id_rsa.pub (when using ssh between postfix and sympa)
RUN mkdir /var/lib/sympa/.ssh/ && chmod 700 /var/lib/sympa/.ssh/ && mkdir -p /var/spool/sympa/wwsbounce && mkdir -p /var/spool/sympa/bulk
COPY ./shared/id_rsa.pub /var/lib/sympa/.ssh/

# Update Locale
RUN locale-gen fr_FR.UTF-8 && export LANG=fr_FR.UTF-8
```

