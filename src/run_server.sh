#!/usr/bin/env bash
#######################################################################
#   Author: Renegade-Master
#   Description: Install, update, and start a Generic SteamCMD Dedicated
#     Server instance.
#   License: GNU General Public License v3.0 (see LICENSE)
#######################################################################

# Set to `-x` for Debug logging
set +x

# Start the Server
function start_server() {
    printf "\n### Starting Generic SteamCMD Server...\n"
    timeout "$TIMEOUT" "$BASE_GAME_DIR"/start-server.sh \
        -adminusername "$ADMIN_USERNAME" \
        -adminpassword "$ADMIN_PASSWORD" \
        -ip "$BIND_IP" -port "$QUERY_PORT" \
        -servername "$SERVER_NAME"
}

function apply_postinstall_config() {
    printf "\n### Applying Post Install Configuration...\n"

    # Set the Max Players
    sed -i "s/MaxPlayers=.*/MaxPlayers=$MAX_PLAYERS/g" "$SERVER_CONFIG"

    # Set the maximum amount of RAM for the JVM
    sed -i "s/-Xmx.*/-Xmx$MAX_RAM\",/g" "$SERVER_VM_CONFIG"

    # Set the Mod names
    sed -i "s/Mods=.*/Mods=$MOD_NAMES/g" "$SERVER_CONFIG"

    # Set the Server Publicity status
    sed -i "s/Open=.*/Open=$PUBLIC_SERVER/g" "$SERVER_CONFIG"

    # Set the Server query Port
    sed -i "s/DefaultPort=.*/DefaultPort=$QUERY_PORT/g" "$SERVER_CONFIG"

    # Set the Server Name
    sed -i "s/PublicName=.*/PublicName=$SERVER_NAME/g" "$SERVER_CONFIG"

    # Set the Server Password
    sed -i "s/Password=.*/Password=$SERVER_PASSWORD/g" "$SERVER_CONFIG"

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
    printf "\n### Updating Generic SteamCMD Server...\n"

    "$STEAM_PATH" +runscript "$STEAM_INSTALL_FILE"

    printf "\n### Generic SteamCMD Server updated.\n"
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
    BASE_GAME_DIR="/home/steam/REPLACE_ME_INSTALL"
    CONFIG_DIR="/home/steam/REPLACE_ME_CONFIG"

    # Set the Server Admin Password variable
    ADMIN_USERNAME=${ADMIN_USERNAME:-"admin"}

    # Set the Server Admin Password variable
    ADMIN_PASSWORD=${ADMIN_PASSWORD:-"changeme"}

    # Set the IP address variable
    BIND_IP=${BIND_IP:-"0.0.0.0"}

    # Set the IP Game Port variable
    GAME_PORT=${GAME_PORT:-"8766"}

    # Set the game version variable
    GAME_VERSION=${GAME_VERSION:-"public"}

    # Set the Max Players variable
    MAX_PLAYERS=${MAX_PLAYERS:-"16"}

    # Set the Maximum RAM variable
    MAX_RAM=${MAX_RAM:-"4096m"}

    # Set the Mods to use from workshop
    MOD_NAMES=${MOD_NAMES:-""}

    # Set the Server Publicity variable
    PUBLIC_SERVER=${PUBLIC_SERVER:-"true"}

    # Set the IP Query Port variable
    QUERY_PORT=${QUERY_PORT:-"16261"}

    # Set the Server name variable
    SERVER_NAME=${SERVER_NAME:-"DedicatedServer"}

    # Set the Server Password variable
    SERVER_PASSWORD=${SERVER_PASSWORD:-""}

    SERVER_CONFIG="$CONFIG_DIR/Server/$SERVER_NAME.ini"
    SERVER_VM_CONFIG="$BASE_GAME_DIR/ProjectZomboid64.json"
    SERVER_RULES_CONFIG="$CONFIG_DIR/Server/${SERVER_NAME}_SandboxVars.lua"
}

## Main
set_variables
update_folder_permissions
apply_preinstall_config
update_server
test_first_run
apply_postinstall_config
start_server
