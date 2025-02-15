#!/bin/sh

# check if PORT variable is set; otherwise, use default port
if [ -z ${PORT+x} ]; then
  echo "PORT variable not defined, leaving N8N to default port."
else
  export N8N_PORT="$PORT"
  echo "N8N will start on '$PORT'"
fi

if [ -n "$DATABASE_URL" ]; then
  # regex function to parse DATABASE_URL
  parse_url() {
    eval $(echo "$1" | sed -e "s#^\(\(.*\)://\)\?\(\([^:@]*\)\(:\(.*\)\)\?@\)\?\([^/?]*\)\(/\(.*\)\)\?#${PREFIX:-URL_}SCHEME='\2' ${PREFIX:-URL_}USER='\4' ${PREFIX:-URL_}PASSWORD='\6' ${PREFIX:-URL_}HOSTPORT='\7' ${PREFIX:-URL_}DATABASE='\9'#")
  }

  # Use a prefix to avoid conflicts and run the parser
  PREFIX="N8N_DB_" parse_url "$DATABASE_URL"
  echo "$N8N_DB_SCHEME://$N8N_DB_USER:$N8N_DB_PASSWORD@$N8N_DB_HOSTPORT/$N8N_DB_DATABASE"

  # Separate host and port
  N8N_DB_HOST="$(echo $N8N_DB_HOSTPORT | sed -e 's,:.*,,g')"
  N8N_DB_PORT="$(echo $N8N_DB_HOSTPORT | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"

  export DB_TYPE=postgresdb
  export DB_POSTGRESDB_HOST=$N8N_DB_HOST
  export DB_POSTGRESDB_PORT=$N8N_DB_PORT
  export DB_POSTGRESDB_DATABASE=$N8N_DB_DATABASE
  export DB_POSTGRESDB_USER=$N8N_DB_USER
  export DB_POSTGRESDB_PASSWORD=$N8N_DB_PASSWORD
else
  echo "DATABASE_URL not set. Skipping DB configuration."
fi

# kickstart nodemation
n8n
