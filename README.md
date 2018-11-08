# Data Platform Sandbox Environment with Docker-Compose

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

### Clone dp-composer and initialize

Clone dp-composer and initialize using the following commands (git pull them if you already have them):

```
cd ~/repos
git clone git@github.com:ps-dev/dvs-sandbox.git
```

*Note: In this example, we place dp-composer somewhere below the User's home directory. This is required on Windows.
For other platforms, you may place the repo anywhere.*


## Bash Aliases

Add these to ~/.bashrc (or sometimes ~/.bash_profile)

```bash
export COMPOSER_HOME=~/repos/dvs-sandbox
alias ddir='cd $COMPOSER_HOME'
alias dfresh='$COMPOSER_HOME/scripts/refresh.sh'
alias dstart='cd $COMPOSER_HOME && docker-compose up -d && cd - > /dev/null'
alias dstop='cd $COMPOSER_HOME && docker-compose stop && cd - > /dev/null'
alias dps='cd $COMPOSER_HOME && docker-compose ps && cd - > /dev/null'
```

### Start docker containers

- Run `dfresh`
- Run `dps` or `docker-compose ps` and make sure all containers are running.  If not, you can start them individually `docker-compose start <container that failed to start> or check the logs with `docker-compose logs <containerName>.
