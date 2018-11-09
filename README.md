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

Now that our environment is ready, we can start to ingest and replicate data.  The first step is to define the metadata for our ingest stream.  For the exact semantics surrounding the metadata payload, please refer to the [Metadata Documentation](https://hydra-ps.atlassian.net/wiki/spaces/DES/pages/7176245/Metadata+Management+Overview).

We've made a collection of HTTP calls in Postman that will help you get off the ground quickly.  First log into Postman using your Okta single sign-on credentials.  Next, look for the drop-down at the top that will allow you to select a team folder and select `data-platform`.  From here, you should see a collection titled `dvs-sandbox`.  Run the scripts in order:

1. Create Topic Metadata
2. Ingest Data
3. Create Replication Job
