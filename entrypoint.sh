#!/bin/bash

updatePostgres() {
    createHydraUser
    createHydraJobsTable
}

createHydraUser() {
  echo "Creating user hydra_root..."
  psql -h postgres -U postgres -c "CREATE USER hydra_root WITH SUPERUSER CREATEDB LOGIN"
}

createHydraJobsTable() {
  psql -h postgres -U postgres -c \
    "CREATE TABLE \"HYDRA_JOBS\" (
        \"JOB_ID\"          VARCHAR(255)                  NOT NULL PRIMARY KEY,
        \"JOB_TYPE\"        VARCHAR(255)                  NOT NULL,
        \"STATUS\"          VARCHAR(255)                  NOT NULL,
        \"START_TIME\"      TIMESTAMP WITHOUT TIME ZONE,
        \"END_TIME\"        TIMESTAMP WITHOUT TIME ZONE,
        \"ERROR\"           TEXT,
        \"JOB_HASH\"        VARCHAR(255)                  NOT NULL,
        \"DSL_TEXT\"        TEXT,
        \"USER_NAME\"       VARCHAR(255)                  DEFAULT NULL,
        \"JOB_NAME\"        VARCHAR(255)                  DEFAULT NULL,
        \"APPLICATION_ID\"  VARCHAR(255)                  DEFAULT NULL
    );"
}

echo "Waiting for postgres to be ready"
curl -I postgres:5432 &> /dev/null
# When postgres is ready curling it will return:
#(52) Empty reply from server
# if it's not ready, it will return:
#(7) Failed to connect to docker port 5432: Connection refused
while [[ "$?" != "52" ]]
do
    echo "Trying again!"
    sleep 1
    curl -I postgres:5432 &> /dev/null
done


updatePostgres