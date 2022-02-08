#######################################################################
#   Author: Renegade-Master
#   Description: Base image for running a Generic SteamCMD Dedicated
#       Server instance.
#   License: GNU General Public License v3.0 (see LICENSE)
#######################################################################

# Set the User and Group IDs
ARG USER_ID=1000
ARG GROUP_ID=1000

FROM renegademaster/steamcmd-minimal:1.0.0
ARG USER_ID
ARG GROUP_ID

# Add metadata labels
LABEL com.renegademaster.steamcmd-dedicated-server-template.authors="Renegade-Master" \
    com.renegademaster.steamcmd-dedicated-server-template.source-repository="https://github.com/Renegade-Master/steamcmd-dedicated-server-template" \
    com.renegademaster.steamcmd-dedicated-server-template.image-repository="https://hub.docker.com/renegademaster/steamcmd-dedicated-server-template"

# Copy the source files
COPY src /home/steam/

# Temporarily login as root to modify ownership
USER 0:0
RUN chown -R ${USER_ID}:${GROUP_ID} "/home/steam"

# Switch to the Steam User
USER ${USER_ID}:${GROUP_ID}

# Run the setup script
ENTRYPOINT ["/bin/bash", "/home/steam/run_server.sh"]
