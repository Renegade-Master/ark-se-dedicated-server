# SteamCMD Dedicated Server Template

## Disclaimer

**Note:** This image is not officially supported by Valve.

If issues are encountered, please report them on
the [GitHub repository](https://github.com/Renegade-Master/steamcmd-dedicated-server-template/issues/new/choose)

## Description

Template for creating SteamCMD Dedicated Servers using Docker, and optionally Docker-Compose.  
Built almost from scratch to be the smallest Dedicated Servers around!

This template was constructed based on the [Project Zomboid Dedicated Server](https://github.com/Renegade-Master/zomboid-dedicated-server)
image, and there may be some holdovers specific to that implementation.

## Links

Source:

- [GitHub](https://github.com/Renegade-Master/steamcmd-dedicated-server-template)

Resource links:

- [Dedicated Server Wiki](https://developer.valvesoftware.com/wiki/SteamCMD)

## Instructions

The server can be run using plain Docker, or using Docker-Compose. The end-result is the same, but Docker-Compose is 
recommended.

*Optional arguments table*:

| Argument          | Description                                                            | Values            | Default         |
|-------------------|------------------------------------------------------------------------|-------------------|-----------------|
| `ADMIN_PASSWORD`  | Server Admin account password                                          | [a-zA-Z0-9]+      | changeme        |
| `ADMIN_USERNAME`  | Server Admin account username                                          | [a-zA-Z0-9]+      | superuser       |
| `BIND_IP`         | IP to bind the server to                                               | 0.0.0.0           | 0.0.0.0         |
| `GAME_PORT`       | Port for sending game data to clients                                  | 1000 - 65535      | 8766            |
| `GAME_VERSION`    | Game version to serve                                                  | [a-zA-Z0-9_]+     | `public`        |
| `MAX_PLAYERS`     | Maximum players allowed in the Server                                  | [0-9]+            | 16              |
| `MAX_RAM`         | Maximum amount of RAM to be used                                       | ([0-9]+)m         | 4096m           |
| `MOD_NAMES`       | Workshop Mod Names (e.g. ClaimNonResidential;MoreDescriptionForTraits) | mod1;mod2;mod     |                 |
| `PUBLIC_SERVER`   | Is the server displayed Publicly                                       | (true&vert;false) | true            |
| `QUERY_PORT`      | Port for other players to connect to                                   | 1000 - 65535      | 16261           |
| `SERVER_NAME`     | Publicly visible Server Name                                           | [a-zA-Z0-9]+      | DedicatedServer |
| `SERVER_PASSWORD` | Server password                                                        | [a-zA-Z0-9]+      |                 |

### Docker

The following are instructions for running the server using the Docker image.

1. Acquire the image locally:
    * Pull the image from DockerHub:

      ```shell
      docker pull renegademaster/steamcmd-dedicated-server-template:<tagname>
      ```
    * Or alternatively, build the image:

      ```shell
      git clone https://github.com/Renegade-Master/steamcmd-dedicated-server-template.git \
          && cd steamcmd-dedicated-server-template

      docker build -t renegademaster/steamcmd-dedicated-server-template:<tag> -f docker/steamcmd-dedicated-server-template.Dockerfile .
      ```

2. Run the container:  

   ***Note**: Arguments inside square brackets are optional. If the default ports are to be overridden, then the
   `published` ports below must also be changed*  

   ```shell
   mkdir REPLACE_ME_CONFIG REPLACE_ME_INSTALL

   docker run --detach \
       --mount type=bind,source="$(pwd)/REPLACE_ME_INSTALL",target=/home/steam/REPLACE_ME_INSTALL \
       --mount type=bind,source="$(pwd)/REPLACE_ME_CONFIG",target=/home/steam/REPLACE_ME_CONFIG \
       --publish 16261:16261/udp --publish 8766:8766/udp \
       --name dedicated-server \
       --user=$(id -u):$(id -g) \
       [--env=ADMIN_PASSWORD=<value>] \
       [--env=ADMIN_USERNAME=<value>] \
       [--env=BIND_IP=<value>] \
       [--env=GAME_PORT=<value>] \
       [--env=GAME_VERSION=<value>] \
       [--env=MAX_PLAYERS=<value>] \
       [--env=MAX_RAM=<value>] \
       [--env=MOD_NAMES=<value>] \
       [--env=PUBLIC_SERVER=<value>] \
       [--env=QUERY_PORT=<value>] \
       [--env=SERVER_NAME=<value>] \
       [--env=SERVER_PASSWORD=<value>] \
       renegademaster/steamcmd-dedicated-server-template[:<tagname>]
   ```

4. Once you see `<placeholder_initialisation_text>` in the console, people can start to join the server.

### Docker-Compose

The following are instructions for running the server using Docker-Compose.

1. Download the repository:

   ```shell
   git clone https://github.com/Renegade-Master/steamcmd-dedicated-server-template.git \
       && cd steamcmd-dedicated-server-template
   ```

2. Make any configuration changes you want to in the `docker-compose.yaml` file. In
   the `services.server.environment` section, you can change values for the server configuration.

   ***Note**: If the default ports are to be overridden, then the `published` ports must also be changed*

3. In the `docker-compose.yaml` file, you must change the `service.server.user` values to match your local user.
   To find your local user and group ids, run the following command:

   ```shell
   printf "UID: %s\nGID: %s\n" $(id -u) $(id -g)
   ```

4. Run the following commands:

   ```shell
   mkdir REPLACE_ME_CONFIG REPLACE_ME_INSTALL

   docker-compose up --build --detach
   ```

6. Once you see `<placeholder_initialisation_text>` in the console, people can start to join the server.
