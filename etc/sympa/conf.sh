#!/bin/bash
# 
# Apply this configuration to the sympa.conf file.
# The script makes a backup of the sympa.conf to sympa.conf.tpl if
# sympa.conf.tpl does't exists and replaces the ${VARIABLES} using the CONF
# variables. 
# Feel free to improve
#
CONF=(
  DOMAIN=localhost
  LISTMASTER=root@localhost.localdomain
  WWSYMPA_URL=http://localhost/lists
  COOKIE=GenerateSring
  DB_HOST=localhost
  DB_PASSWD=password
  HTTP_HOST=http://localhost/
  SOAP_URL=http://localhost/sympasoap
)

function applyConf() {
  if [ ! -f sympa.conf.tpl ] ; then
    cp sympa.conf sympa.conf.tpl
  else 
    cp sympa.conf.tpl sympa.conf
  fi
  for c in ${CONF[*]} ; do
    name=$(echo $c |cut -d "=" -f1)
    value=$(echo $c |cut -d "=" -f2|sed -e "s/\//\\\\\//g")
    sed -e "s/\${$name}/$value/" sympa.conf  -i
  done
}

applyConf
