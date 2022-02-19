#!/usr/bin/env bash

#
#  ARK: Survival Evolved Dedicated Server using SteamCMD Docker Image.
#  Copyright (C) 2021-2022 Renegade-Master [renegade.master.dev@protonmail.com]
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.
#


#######################################################################
#   Author: Renegade-Master
#   Description: Install, update, and start an ARK: Survival Evolved
#     Dedicated Server instance.
#######################################################################

# Set to `-x` for Debug logging
set +x -u -o pipefail

# Start the Server
start_server() {
    printf "\n### Starting ARK Survival Evolved Server...\n"

    timeout "$TIMEOUT" "$BASE_GAME_DIR"/ShooterGame/Binaries/Linux/ShooterGameServer \
    "$MAP_NAME"?listen?SessionName="$SERVER_NAME"?ServerPassword="$SERVER_PASSWORD"?ServerAdminPassword="$ADMIN_PASSWORD"?Port="$GAME_PORT"?QueryPort="$QUERY_PORT"?MaxPlayers="$MAX_PLAYERS" \
    -servergamelog
}

apply_postinstall_config() {
    printf "\n### Applying Post Install Configuration...\n"

    # Remove the repeated key in the config file
    uniq "$SERVER_CONFIG" > "${SERVER_CONFIG}2"
    mv "${SERVER_CONFIG}2" "$SERVER_CONFIG"

    printf "\n### Post Install Configuration applied.\n"
}

# Test if this is the the first time the server has run
test_first_run() {
    printf "\n### Checking if this is the first run...\n"

    if [[ ! -f "$SERVER_CONFIG" ]] || [[ ! -f "$SERVER_RULES_CONFIG" ]]; then
        printf "\n### This is the first run.\nStarting server for %s seconds\n" "$TIMEOUT"
        start_server || true
        TIMEOUT=0
    else
        printf "\n### This is not the first run.\n"
        TIMEOUT=0
    fi

    printf "\n### First run check complete.\n"
}

# Update the server
update_server() {
    printf "\n### Updating ARK Survival Evolved Server...\n"

    install_success=1
    retries=0

    # Try at most 3 times to install the server
    while [[ "$install_success" -ne 0 ]] && [[ "$retries" -lt 3 ]]; do
        printf "\n### Attempt %s to update ARK: Survival Evolved Server...\n" "$retries"

        # Redirect subshell output to STDOUT using a File Descriptor
        exec 3>&1

        # Attempt to update the server
        steam_output=$("$STEAM_PATH" +runscript "$STEAM_INSTALL_FILE" | tee /dev/fd/3)

        # Close the File Descriptor
        exec 3>&-

        # Check if the update was successful
        if [[ $steam_output == *"Success! App '376030' fully installed."* ]]; then
            install_success=0
        else
            retries=$((retries + 1))
        fi
    done

    # Exit is the installation was unsuccessful
    if [[ "$install_success" -ne 0 ]]; then
        printf "\n### Failed to update ARK: Survival Evolved Server.\n"
        exit 1
    fi

    printf "\n### ARK Survival Evolved Server updated.\n"
}

# Apply user configuration to the server
apply_preinstall_config() {
    printf "\n### Applying Pre Install Configuration...\n"

    # Set the selected game version
    sed -i "s/beta .* /beta $GAME_VERSION /g" "$STEAM_INSTALL_FILE"

    printf "\n### Pre Install Configuration applied.\n"
}

# Change the folder permissions for install and save directory
update_folder_permissions() {
    printf "\n### Updating Folder Permissions...\n"

    chown -R "$(id -u):$(id -g)" "$BASE_GAME_DIR"

    printf "\n### Folder Permissions updated.\n"
}

# Set variables for use in the script
set_variables() {
    printf "\n### Setting variables...\n"

    TIMEOUT="60"
    STEAM_INSTALL_FILE="/home/steam/install_server.scmd"
    BASE_GAME_DIR="/home/steam/ArkSE_Install"
    CONFIG_DIR="/home/steam/ArkSE_Install/ShooterGame/Saved"

    # Set the Server Admin Password variable
    ADMIN_PASSWORD=${ADMIN_PASSWORD:-"changeme"}

    # Set the IP Game Port variable
    GAME_PORT=${GAME_PORT:-"7777"}

    # Set the second IP Game Port variable
    GAME_PORT_2=${GAME_PORT_2:-"7778"}

    # Set the game version variable
    GAME_VERSION=${GAME_VERSION:-"public"}

    # Set the Map to load
    MAP_NAME=${MAP_NAME:-"TheIsland"}

    # Set the Max Players variable
    MAX_PLAYERS=${MAX_PLAYERS:-"16"}

    # Set the IP Query Port variable
    QUERY_PORT=${QUERY_PORT:-"27015"}

    # Set the Server name variable
    SERVER_NAME=${SERVER_NAME:-"ArkSeServer"}

    # Set the Server Password variable
    SERVER_PASSWORD=${SERVER_PASSWORD:-""}

    SERVER_CONFIG="$CONFIG_DIR/Config/LinuxServer/GameUserSettings.ini"
    SERVER_RULES_CONFIG="$CONFIG_DIR/Config/LinuxServer/Game.ini"
}

## Main
set_variables
update_folder_permissions
apply_preinstall_config
update_server
test_first_run
apply_postinstall_config
start_server
