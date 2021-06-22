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
git clone https://github.com/opensentry/dev.git
cd dev
```


## Production [Under construction]
...

## Development
To get up and running in development mode on localhost, you can follow this process.

### Configuration

*Run commands from project root directory*

Copy config files from def to use folder:
```bash
cp config/def/* config/use
```

#### Secrets

The following command generates random secrets and matches them across files.

##### Linux
The following command generates random secrets and matches them across files.
```bash
# LC_TYPE is required on macOS
LC_CTYPE=C prefix=(mail_ neo4j_ mysql_); for i in "${prefix[@]}"; do PW=$(</dev/urandom tr -dc A-Za-z0-9|head -c96); find config/use -type f -exec sed -i -e "s/\b${i}youreallyneedtochangethis_64\b/${PW:0:64}/" -e "s/\b${i}youreallyneedtochangethis_32\b/${PW:64:32}/" {} \+; done
```

Next we'll need to add some standalone random secrets
```
grep -sire "\byoureallyneedtochangethis_[0-9]*\b" config/use/** | cut -d : -f 1 | while read line; do PW=$(cat /dev/urandom | tr -dc A-Za-z0-9|head -c96); sed -i -e "0,/\byoureallyneedtochangethis_32\b/ s/\byoureallyneedtochangethis_32\b/${PW:0:32}/" -e "0,/\byoureallyneedtochangethis_64\b/ s/\byoureallyneedtochangethis_64\b/${PW:32:64}/" $line; done
```

##### MacOS
```bash
# LC_TYPE is required on macOS
LC_CTYPE=C prefix=(mail_ neo4j_ mysql_); for i in "${prefix[@]}"; do PW=$(</dev/urandom tr -dc A-Za-z0-9|head -c96); find config/use -type f -exec sed -i '' -e "s/${i}youreallyneedtochangethis_64/${PW:0:64}/" -e "s/${i}youreallyneedtochangethis_32/${PW:64:32}/" {} \;; done
```

Next we'll need to add some standalone random secrets
```
grep -sire "youreallyneedtochangethis_[0-9]*" config/use/** | cut -d : -f 1 | while read line; do PW=$(cat /dev/urandom | tr -dc A-Za-z0-9|head -c96); sed -i '' -e "1,/youreallyneedtochangethis_32/ s/youreallyneedtochangethis_32/${PW:0:32}/" -e "1,/youreallyneedtochangethis_64/ s/youreallyneedtochangethis_64/${PW:32:64}/" $line; done
```

Check if it looks correct:
```bash
diff -u config/def config/use
```

#### Domains

Change `/etc/hosts` on the dev machine to include the following
```
127.0.0.1     localhost oauth.localhost id.localhost aa.localhost me.localhost
```

#### Quick replace domains (optional)

To change all configurations urls (localhost), execute within the dev root directory:
```bash
find config/use -type f -exec sed -i -e s/aa.localhost/aa.test.com/g -e s/id.localhost/id.test.com/g -e s/oauth.localhost/oauth.test.com/g -e s/me.localhost/me.test.com/g {} \;
```

*Remember to fix your host file after this operation*

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

# Setup Mutt as a dev mail client

Mutt can be used to see mails from the system (postfix)

## Install
```
brew install mutt
```

## Configuration
Add a `.muttrc`to your `$HOME` folder with the following content:
```
set mbox_type=Maildir
set folder=~/Maildir/dev
set spoolfile=+/
set header_cache=~/.cache/mutt
```


# Useful hydra terminal commands

curl -X DELETE http://oauth.localhost:4445/oauth2/auth/sessions/consent?subject=user1 -H 'Accept: application/json'

## Token introspection
docker run --rm -it -e HYDRA_ADMIN_URL=https://hydra:4445 --network opensentry_trusted oryd/hydra token introspect --skip-tls-verify$TOKEN

## List clients
docker run --rm -it -e HYDRA_ADMIN_URL=https://hydra:4445 --network opensentry_trusted oryd/hydra clients list --skip-tls-verify

## Show client
docker run --rm -it -e HYDRA_ADMIN_URL=https://hydra:4445 --network opensentry_trusted oryd/hydra clients get --skip-tls-verify $CLIENT_ID

## Delete client
docker run --rm -it -e HYDRA_ADMIN_URL=http://hydra:4445 --network opensentry_trusted oryd/hydra clients delete --skip-tls-verify $CLIENT_ID
