# Getting started

To get up and running a machine docker and docker-compose is required. Good guides are for this are

https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04
https://docs.docker.com/compose/install/


Download the idp project
```bash
mkdir git
cd git
git clone https://github.com/opensentry/idp.git
git clone https://github.com/opensentry/idpui.git
git clone https://github.com/opensentry/aap.git
git clone https://github.com/opensentry/aapui.git
git clone https://github.com/opensentry/meui.git
git clone https://github.com/opensentry/opensentry-dev.git
cd opensentry-dev
```


## Production [Under construction]
...

## Development
To get up and running in development mode on localhost, you can follow this process:

Change `/etc/hosts` on the machine to include
```
127.0.0.1     localhost oauth.localhost id.localhost aa.localhost me.localhost
```

### Bring all services up
```bash
docker-compose -f migrations/docker-compose.migrate.certs.yml up && \
docker-compose -f docker-compose.storage.yml up -d && \
docker-compose -f migrations/docker-compose.migrate.hydra.yml up && \
docker-compose -f migrations/docker-compose.migrate.idp.yml up && \
docker-compose -f migrations/docker-compose.migrate.aap.yml up && \
docker-compose -f docker-compose.services.yml up -d oathkeeper && \
docker-compose -f docker-compose.services.yml up -d hydra && \
docker-compose -f migrations/docker-compose.migrate.clients.yml up && \
docker build   -t opensentry-dev -f Dockerfile . --no-cache  && \
docker-compose -f docker-compose.services.yml up -d
```

### No migration/building version
```bash
docker-compose -f docker-compose.storage.yml up -d && \
docker-compose -f docker-compose.services.yml up -d
```

### Commands to view logs
docker-compose -f docker-compose.services.yml logs -f idp idpui aap aapui meui hydra


### fast replace

To change all configurations urls (localhost), execute within the opensentry-dev root directory:
```bash
find config -type f -exec sed -i -e s/aa.localhost/aa.test.com/g -e s/id.localhost/id.test.com/g -e s/oauth.localhost/oauth.test.com/g -e s/me.localhost/me.test.com/g {} \;
```

### Generate random secrets

*Run commands from root directory*

Copy from def to use folder:
```
cp config/def/* config/use
```

```
secrets=("" mail_ neo4j_ mysql_); for i in "${secrets[@]}"; do find config -type f ! -name README\.md -path ./config/def -exec sed -i -e "s/\b`echo $i`youreallyneedtochangethis_64\b/`< /dev/urandom tr -dc A-Za-z0-9 | head -c64`/" {} \;; done
secrets=("" mail_ neo4j_ mysql_); for i in "${secrets[@]}"; do find config -type f ! -name README\.md -path ./config/def -exec sed -i -e "s/\b`echo $i`youreallyneedtochangethis_32\b/`< /dev/urandom tr -dc A-Za-z0-9 | head -c32`/" {} \;; done
```

# Useful hydra terminal commands

curl -X DELETE http://oauth.localhost:4445/oauth2/auth/sessions/consent?subject=user1 -H 'Accept: application/json'

## Token introspection
docker run --rm -it -e HYDRA_ADMIN_URL=https://hydra:4445 --network opensentry_trusted oryd/hydra --skip-tls-verify token introspect $TOKEN

## List clients
docker run --rm -it -e HYDRA_ADMIN_URL=https://hydra:4445 --network opensentry_trusted oryd/hydra --skip-tls-verify clients list

## Show client
docker run --rm -it -e HYDRA_ADMIN_URL=https://hydra:4445 --network opensentry_trusted oryd/hydra --skip-tls-verify clients get $CLIENT_ID

## Delete client
docker run --rm -it -e HYDRA_ADMIN_URL=http://hydra:4445 --network opensentry_trusted oryd/hydra clients delete $CLIENT_ID
