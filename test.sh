#!/bin/sh

set -e

cleanup_docker=0
cleanup_mailhog=0
cleanup_pgsql=0
cleanup_network=0
cleanup() {
  set +e

  if [ "$cleanup_docker" -ne 0 ]; then
    echo "Logs"
    docker logs sympa

    echo "Stopping Docker image"
    docker stop sympa
    docker rm -f sympa
    rm -rf test/id_rsa* test/known_hosts*
  fi

  if [ "$cleanup_mailhog" -ne 0 ]; then
    echo "Logs mailhog"
    docker logs mailhog

    echo "Stopping mailhog Docker image"
    docker stop mailhog
    docker rm -f mailhog
  fi

  if [ "$cleanup_pgsql" -ne 0 ]; then
    echo "Logs pgsql"
    docker logs pgsql

    echo "Stopping pgsql Docker image"
    docker stop pgsql
    docker rm -f pgsql
  fi

  if [ "$cleanup_network" -ne 0 ]; then
    echo "Removing Docker network"
    docker network rm testnet
  fi
}

trap cleanup EXIT

echo "Creating Docker network"
time docker network create testnet
cleanup_network=1

echo "Preparing"
apk add --no-cache jq

echo "Running pgsql Docker image"
docker run -d --name pgsql --network testnet -e LOG_TO_STDOUT=1 -e PGSQL_ROLE_1_USERNAME=sympa -e PGSQL_ROLE_1_PASSWORD=password -e PGSQL_DB_1_NAME=sympa -e PGSQL_DB_1_OWNER=sympa registry.gitlab.com/tozd/docker/postgresql:14
cleanup_pgsql=1

echo "Running mailhog Docker image"
docker run -d --name mailhog --network testnet -p 8025:8025 mailhog/mailhog:v1.0.1 -hostname mailhog -smtp-bind-addr :25
cleanup_mailhog=1

echo "Sleeping"
sleep 10

echo "Running Docker image"
docker run -d --name sympa --network testnet --network-alias example.com -e LOG_TO_STDOUT=1 -e REMOTES=mailhog -v "$(pwd)/test:/etc/sympa/shared" -p 80:80 "${CI_REGISTRY_IMAGE}:${TAG}"
cleanup_docker=1

echo "Sleeping"
sleep 20

echo "Testing web"
docker run --rm --network testnet curlimages/curl:8.1.2 curl -s http://example.com/lists | grep '<title> Mailing lists - lists </title>'
echo "Success"

echo "Testing mailing list"
# We create example@example.com mailing list.
docker exec sympa chpst -u sympa:sympa /usr/lib/sympa/bin/sympa.pl --create_list --robot example.com --input_file=/etc/sympa/shared/list.xml
# We subscribe user@example.com to the mailing list.
echo "user@example.com" | docker exec -i sympa chpst -u sympa:sympa /usr/lib/sympa/bin/sympa.pl --add=example@example.com
# We send over SSH a mail to the mailing list (like postfix would do).
/bin/echo -e "Subject: test\nFrom: user@example.com\nTo: example@example.com\nMessage-ID: 123@example.com" | docker run -i --rm --network testnet -v "$(pwd)/test:/root/.ssh" docker:23-cli ssh -T sympa@sympa queue example@example.com

echo "Sleeping"
sleep 10

# The first e-mail is about database structure which was initialized.
wget -q -O - http://docker:8025/api/v2/messages | jq -r .items[2].Content.Headers.From[0] | grep -F "SYMPA <sympa@example.com>"
wget -q -O - http://docker:8025/api/v2/messages | jq -r .items[2].Content.Headers.To[0] | grep -F "Listmaster <listmaster@example.com>"
wget -q -O - http://docker:8025/api/v2/messages | jq -r .items[2].Content.Headers.Subject[0] | grep -F "Database structure updated"

# The second e-mail is that the user got subscribed.
wget -q -O - http://docker:8025/api/v2/messages | jq -r .items[1].Content.Headers.From[0] | grep -F "example-request@example.com"
wget -q -O - http://docker:8025/api/v2/messages | jq -r .items[1].Content.Headers.To[0] | grep -F "user@example.com"
wget -q -O - http://docker:8025/api/v2/messages | jq -r .items[1].Content.Headers.Subject[0] | grep -F "Welcome to list example"

# The third e-mail is what we sent to example@example.com mailing list.
wget -q -O - http://docker:8025/api/v2/messages | jq -r .items[0].Raw.From | grep -F "example-owner@example.com"
wget -q -O - http://docker:8025/api/v2/messages | jq -r .items[0].Raw.To[0] | grep -F "user@example.com"

echo "Success"
