#!/bin/bash

docker compose up -d

read -r -d '' QUERY_MAIN_FIELDS << EOF
  id,
  uuid,
  title,
  case when char_length(article) > 20 then
    concat(substring(article, 1, 20), '...')
  else
    article
  end AS article
FROM articles
LIMIT 10
EOF

MY_HOST_QUERY="SELECT host AS 'Query sent from Host' FROM INFORMATION_SCHEMA.PROCESSLIST WHERE id = CONNECTION_ID()"

echo "Querying directly to the database (LIMIT 10)..."
# Given the preconfigured database
# And a dedicated "local" query
# When we SELECT everything
echo "SELECT \"LOCAL\" AS via, $QUERY_MAIN_FIELDS; $MY_HOST_QUERY;" \
  | docker compose exec --no-TTY db mysql -h 127.0.0.1 -u root -proot -D example
# command: `docker compose exec`
# args: `--no-TTY db mysql`
# https://docs.docker.com/engine/reference/commandline/compose_exec/
# The intent here is we are going to run a specific command, within a running container
# and we are indicating not to allocate a TTY (because stdin is not a TTY it is piped data)
# and the program we are executing inside, is the mysql binary
# mysql args: -h 127.0.0.1 -u root -proot -D example
# try `docker compose exec db mysql --help` for details

# Then lots of rows of "articles" will be output

printf "Press any key to continue" && read -n 1 line && printf "\n"

echo "Querying from a remote host to the database (LIMIT 10)..."
# Given we can't access the DB directly (for example the DB is in a private subnet)
# When we SELECT everything (via ssh)
echo "SELECT \"SHH via remote host\" AS via, $QUERY_MAIN_FIELDS; $MY_HOST_QUERY;" \
  | docker compose run --rm --interactive --no-TTY local ssh remote "mysql -h db -u root -proot -D example"
# Note: the use of docker-compose here is intentional. For some reason 
# Note: runs a fresh copy of the local container, ssh over to the remote container, and run mysql connecting to the db container
# Then lots of rows of "articles" will be output
# command: `docker compose run`
# args: `--rm --interactive --no-TTY local ssh`
# The intent of this command will be to run a new container based on the "local" container spec in the compose file.
# Once within the container, we run the ssh command, and then run a command on the remote system.
# Once the container is complete we want to remove the container (--rm) as to keep our compose environment clean.
# ssh args: `remote "mysql -h db -u root -proot -D example"`
# try `docker compose run --rm local ssh` for additional help.
# The command will ssh to a host by the name of "remote", and once on the remote host will run:
# mysql -h db -u root -proot -D example
# See earlier command(s) for more details on what these arguments mean.
