# Data Platform Sandbox Environment

## Getting Started

### Install Docker (Community Edition)

- Windows
  - [Install/Setup Dependencies](https://github.com/ps-dev/ps-docker#install-dependencies)
- Linux / Mac
  - [Install Docker](https://www.docker.com/products/overview)

### Install docker-compose

- Linux
  - `sudo apt-get install docker-compose`

### Make sure your user can run docker commands

- Linux
  - `sudo gpasswd -a $USER docker` (literally use the string "$USER", not your user name)

### Verify your user can run docker

- `docker run hello-world`

### Connect to dev vpn

- Install vpn client (i.e. tunnelblick)
- Request VPN config file from #it for devvpn.pluralsight.com. This will come through last pass.

### Recreate default docker VM with correct settings

<!-- 1. Add `10.107.7.144  registry.pluralsight.private` to your hosts file -->

1. Add this Insecure Registry: registry.pluralsight.private:5000
- In Docker for Mac: Preferences -> Daemon -> Insecure Registries

Now let's test a few things to make sure docker is looking good:

- Run `docker ps` and make sure you get happy looking (although sparse) output
- Run `docker pull registry.vnerd.com:5000/ps-cassandra` to make sure you can connect to our private registry
- Run `docker-compose` to make sure it is installed. You should see the help text.

### Add entries to hosts file<a name="hostentries"></a>

Add service aliases to /etc/hosts and map to 127.0.0.1

- `127.0.0.1 localhost docker kafka schema-registry zookeeper`

### Clone dvs-sandbox and initialize

Clone dvs-sandbox and initialize using the following commands (git pull them if you already have them):

```bash
cd ~/repos
git clone git@github.com:ps-dev/dvs-sandbox.git
```

*Note: In this example, we place dvs-sandbox somewhere below the User's home directory. This is required on Windows.
For other platforms, you may place the repo anywhere.*

### Start docker containers

- Run `docker-compose up -d` to start all containers.
- Run `docker-compose ps` and make sure all containers are running (there is a `bootstrap-postgres` container that will have existed.  This is ok).  If not, you can start them individually `docker-compose start <container that failed to start>` or check the logs with `docker-compose logs <containerName>`.

## Sample DVS Workflow

The basic workflow for using DVS consists of:

1. [Create Topic Metadata](#create-topic-metadata)
2. [Ingest Data](#ingest-data)
3. [Create Replication Job](#create-replication-job)

NOTE: We've made a collection of HTTP calls in Postman that will help you get off the ground quickly.  First log into Postman using your Okta single sign-on credentials.  Next, look for the drop-down at the top that will allow you to select a team folder and select `data-platform`.  From here, you should see a collection titled `dvs-sandbox`.

### Create Topic Metadata

Before we can ingest data, we need to configure DVS.  We will need the topic metadata and the schema.  For the exact semantics surrounding the metadata payload, please refer to the [Metadata Documentation](https://hydra-ps.atlassian.net/wiki/spaces/DES/pages/7176245/Metadata+Management+Overview).

You can use the Postman template noted above.  But if you prefer the command line, here's how you can use `curl` to post the metadata payload to ingest:

```bash
curl -X POST \
  http://localhost:8088/topics \
  -H 'Content-Type: application/json' \
  -d '{
    "subject": "exp.data-platform.dvs-sandbox.Test",
    "streamType": "History",
    "derived": false,
    "dataClassification": "Public",
    "contact": "slackity slack dont talk back",
    "notes": "here are some notes topkek",
    "schema": {
        "type": "record",
        "name": "Test",
        "namespace": "exp.data-platform.dvs-sandbox",
        "fields": [
            {
                "name": "id",
                "type": "string"
            },
            {
                "name": "messageNumber",
                "type": "int"
            },
            {
                "name": "messagePublishedAt",
                "type": {
                    "type": "string",
                    "logicalType": "iso-datetime"
                }
            }
        ]
    }
}'
```

### Ingest Data

Next, we can start POSTing data to `/ingest`.  You will see some of the headers below that specify how the data is stored in the DVS.  To get more information on the headers and what they mean, please see the ingest documentation.

```bash
curl -X POST \
  http://localhost:8088/ingest \
  -H 'Content-Type: application/json' \
  -H 'hydra-ack: persisted' \
  -H 'hydra-kafka-topic: exp.data-platform.dvs-sandbox.Test' \
  -d '{
    "id": "5de47f5a-1c4f-4128-b537-4f44faabaaa1",
    "messageNumber": 1,
    "messagePublishedAt": "2018-11-08T01:00:00+00:00"
}'
```

NOTE: To check that your data is being successfully ingested, you can navigate to `http://localhost:8080/streams/exp.dataplatform.TestSubject?start=earliest&groupId=test` in your browser and post a new message.  You should see your payload appear on the screen.

### Create Replication Job

Now that we have some data in the DVS, let's replicate it out to PostgreSQL.  Hydra-streams takes a configuration that tells it where to replicate.  Here's an example below.

```bash
curl -X POST \
  http://localhost:8080/dsl \
  -H 'Content-Type: application/json' \
  -d '{
    "replicate": {
        "applicationId": "data-platform---exp.data-platform.dvs-sandbox.Test",
        "name": "DataPlatform.DvsSandbox.Test",
        "connection": {
            "password": "",
            "url": "jdbc:postgresql://postgres/postgres",
            "user": "postgres"
        },
        "primaryKeys": {
            "ps.data-platform.dvs-sandbox.Test": "id"
        },
        "startingOffsets": "earliest",
        "topics": [
            "exp.data-platform.dvs-sandbox.Test"
        ]
    }
}'
```
To check to make sure that your replication job is running, go to `localhost:8080` in your browser.  In the `Running` jobs section, you should see a job matching `DataPlatform.DvsSandbox.Test`.  To check to make sure the job has consumed all available records, add `/status` to the end of the previous url.  

You can verify the data is in Postgres by using the PostgreSQL client of your choice to the instance running in docker.

```bash
psql -h localhost -U postgres
```

```sql
SELECT * FROM test;
```
