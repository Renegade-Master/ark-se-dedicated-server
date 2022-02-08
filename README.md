# ARK: Survival Evolved Dedicated Server

## Disclaimer

**Note:** This image is not officially supported by Valve, nor by Studio Wildcard.

If issues are encountered, please report them on
the [GitHub repository](https://github.com/Renegade-Master/ark-se-dedicated-server/issues/new/choose)

## Badges

[![Build and Test Server Image](https://github.com/Renegade-Master/ark-se-dedicated-server/actions/workflows/docker-build.yml/badge.svg?branch=main)](https://github.com/Renegade-Master/ark-se-dedicated-server/actions/workflows/docker-build.yml)

![Docker Image Version (latest by date)](https://img.shields.io/docker/v/renegademaster/ark-se-dedicated-server?label=Latest%20Version)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/renegademaster/ark-se-dedicated-server?label=Image%20Size)
![Docker Pulls](https://img.shields.io/docker/pulls/renegademaster/ark-se-dedicated-server?label=Docker%20Pull%20Count)

## Description

Dedicated Server for ARK: Survival Evolved using Docker, and optionally Docker-Compose.  
Built almost from scratch to be the smallest ARK: Survival Evolved Dedicated Server around!

## Links

Source:

- [GitHub](https://github.com/Renegade-Master/ark-se-dedicated-server)
- [DockerHub](https://hub.docker.com/r/renegademaster/ark-se-dedicated-server)

Resource links:

- [Dedicated Server Setup](https://ark.fandom.com/wiki/Dedicated_server_setup)
- [Dedicated Server Configuration](https://ark.fandom.com/wiki/Server_configuration)
- [Steam DB Page](https://steamdb.info/app/376030/)

## Instructions

The server can be run using plain Docker, or using Docker-Compose. The end-result is the same, but Docker-Compose is
recommended.

*Optional arguments table*:

| Argument          | Description                                                            | Values            | Default     |
|-------------------|------------------------------------------------------------------------|-------------------|-------------|
| `ADMIN_PASSWORD`  | Server Admin account password                                          | [a-zA-Z0-9]+      | changeme    |
| `BIND_IP`         | IP to bind the server to                                               | 0.0.0.0           | 0.0.0.0     |
| `GAME_PORT`       | Port for sending game data to clients                                  | 1000 - 65535      | 7777        |
| `GAME_PORT_2`     | Additionally required Port for sending game data to clients            | 1000 - 65535      | 7778        |
| `GAME_VERSION`    | Game version to serve                                                  | [a-zA-Z0-9_]+     | `public`    |
| `MAX_PLAYERS`     | Maximum players allowed in the Server                                  | [0-9]+            | 16          |
| `MAX_RAM`         | Maximum amount of RAM to be used                                       | ([0-9]+)m         | 6144m       |
| `MOD_NAMES`       | Workshop Mod Names (e.g. ClaimNonResidential;MoreDescriptionForTraits) | mod1;mod2;mod     |             |
| `PUBLIC_SERVER`   | Is the server displayed Publicly                                       | (true&vert;false) | true        |
| `QUERY_PORT`      | Port for other players to connect to                                   | 1000 - 65535      | 27015       |
| `SERVER_NAME`     | Publicly visible Server Name                                           | [a-zA-Z0-9]+      | ArkSeServer |
| `SERVER_PASSWORD` | Server password                                                        | [a-zA-Z0-9]+      |             |

### Docker

The following are instructions for running the server using the Docker image.

1. Acquire the image locally:
    * Pull the image from DockerHub:

      ```shell
      docker pull renegademaster/ark-se-dedicated-server:<tagname>
      ```
    * Or alternatively, build the image:

      ```shell
      git clone https://github.com/Renegade-Master/ark-se-dedicated-server.git \
          && cd ark-se-dedicated-server

      docker build -t renegademaster/ark-se-dedicated-server:<tag> -f docker/ark-se-dedicated-server.Dockerfile .
      ```

2. Run the container:

   ***Note**: Arguments inside square brackets are optional. If the default ports are to be overridden, then the
   `published` ports below must also be changed*

   ```shell
   mkdir ArkSE_Install ArkSE_Config

   docker run --detach \
       --mount type=bind,source="$(pwd)/ArkSE_Install",target=/home/steam/ArkSE_Install \
       --mount type=bind,source="$(pwd)/ArkSE_Config",target=/home/steam/ArkSE_Config \
       --publish 27015:27015/udp --publish 7777:7777/udp --publish 7778:7778/udp \
       --name ark-se-server \
       --user=$(id -u):$(id -g) \
       [--env=ADMIN_PASSWORD=<value>] \
       [--env=BIND_IP=<value>] \
       [--env=GAME_PORT=<value>] \
       [--env=GAME_PORT_2=<value>] \
       [--env=GAME_VERSION=<value>] \
       [--env=MAX_PLAYERS=<value>] \
       [--env=MAX_RAM=<value>] \
       [--env=MOD_NAMES=<value>] \
       [--env=QUERY_PORT=<value>] \
       [--env=SERVER_NAME=<value>] \
       [--env=SERVER_PASSWORD=<value>] \
       renegademaster/ark-se-dedicated-server[:<tagname>]
   ```

4. Once you see `<placeholder_initialisation_text>` in the console, people can start to join the server.

### Docker-Compose

The following are instructions for running the server using Docker-Compose.

1. Download the repository:

   ```shell
   git clone https://github.com/Renegade-Master/ark-se-dedicated-server.git \
       && cd ark-se-dedicated-server
   ```

2. Make any configuration changes you want to in the `docker-compose.yaml` file. In
   the `services.ark-se-server.environment` section, you can change values for the server configuration.

   ***Note**: If the default ports are to be overridden, then the `published` ports must also be changed*

3. In the `docker-compose.yaml` file, you must change the `services.ark-se-server.user` values to match your local user.
   To find your local user and group ids, run the following command:

   ```shell
   printf "UID: %s\nGID: %s\n" $(id -u) $(id -g)
   ```

4. Run the following commands:

   ```shell
   mkdir ArkSE_Install ArkSE_Config

   docker-compose up --build --detach
   ```

6. Once you see `<placeholder_initialisation_text>` in the console, people can start to join the server.
