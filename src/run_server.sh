#!/usr/bin/env bash
#######################################################################
#   Author: Renegade-Master
#   Description: Install, update, and start an ARK: Survival Evolved
#     Dedicated Server instance.
#   License: GNU General Public License v3.0 (see LICENSE)
#######################################################################

# Set to `-x` for Debug logging
set +x -eu -o pipefail

# Start the Server
function start_server() {
    printf "\n### Starting ARK Survival Evolved Server...\n"

    timeout "$TIMEOUT" "$BASE_GAME_DIR"/ShooterGame/Binaries/Linux/ShooterGameServer \
        TheIsland?\
        listen?\
        SessionName="$SERVER_NAME"?\
        ServerPassword="$SERVER_PASSWORD"?\
        ServerAdminPassword="$ADMIN_PASSWORD"?\
        Port="$GAME_PORT"?\
        QueryPort="$QUERY_PORT"?\
        MaxPlayers="$MAX_PLAYERS"
}

function apply_postinstall_config() {
    printf "\n### Applying Post Install Configuration...\n"

    # Remove the repeated key in the config file
    uniq "$SERVER_CONFIG" > "${SERVER_CONFIG}2"
    mv "${SERVER_CONFIG}2" "$SERVER_CONFIG"

    # Set the Mod names
    sed -i "s/Mods=.*/Mods=$MOD_NAMES/g" "$SERVER_CONFIG"

    # Set the Server Publicity status
    sed -i "s/Open=.*/Open=$PUBLIC_SERVER/g" "$SERVER_CONFIG"

    printf "\n### Post Install Configuration applied.\n"
}

# Test if this is the the first time the server has run
function test_first_run() {
    printf "\n### Checking if this is the first run...\n"

    if [[ ! -f "$SERVER_CONFIG" ]] || [[ ! -f "$SERVER_RULES_CONFIG" ]]; then
        printf "\n### This is the first run.\nStarting server for %s seconds\n" "$TIMEOUT"
        start_server
        TIMEOUT=0
    else
        printf "\n### This is not the first run.\n"
        TIMEOUT=0
    fi

    printf "\n### First run check complete.\n"
}

# Update the server
function update_server() {
    printf "\n### Updating ARK Survival Evolved Server...\n"

    "$STEAM_PATH" +runscript "$STEAM_INSTALL_FILE"

    printf "\n### ARK Survival Evolved Server updated.\n"
}

# Apply user configuration to the server
function apply_preinstall_config() {
    printf "\n### Applying Pre Install Configuration...\n"

    # Set the selected game version
    sed -i "s/beta .* /beta $GAME_VERSION /g" "$STEAM_INSTALL_FILE"

    printf "\n### Pre Install Configuration applied.\n"
}

# Change the folder permissions for install and save directory
function update_folder_permissions() {
    printf "\n### Updating Folder Permissions...\n"

    chown -R "$(id -u):$(id -g)" "$BASE_GAME_DIR"
    chown -R "$(id -u):$(id -g)" "$CONFIG_DIR"

    printf "\n### Folder Permissions updated.\n"
}

# Set variables for use in the script
function set_variables() {
    printf "\n### Setting variables...\n"

    TIMEOUT="60"
    STEAM_INSTALL_FILE="/home/steam/install_server.scmd"
    BASE_GAME_DIR="/home/steam/ArkSE_Install"
    CONFIG_DIR="/home/steam/ArkSE_Install/ShooterGame/Saved"

    # Set the Server Admin Password variable
    ADMIN_PASSWORD=${ADMIN_PASSWORD:-"changeme"}

    # Set the IP Game Port variable
    GAME_PORT=${GAME_PORT:-"7777"}

    # Set the game version variable
    GAME_VERSION=${GAME_VERSION:-"public"}

    # Set the Max Players variable
    MAX_PLAYERS=${MAX_PLAYERS:-"16"}

    # Set the Maximum RAM variable
    MAX_RAM=${MAX_RAM:-"6144m"}

    # Set the Mods to use from workshop
    MOD_NAMES=${MOD_NAMES:-""}

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
