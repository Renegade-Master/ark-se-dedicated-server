#!/usr/bin/env python3

#   ARK: Survival Evolved Dedicated Server using SteamCMD Docker Image.
#   Copyright (C) 2021-2022 Renegade-Master [renegade.master.dev@protonmail.com]
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.

"""
Author: Renegade-Master
Description:
    Script for editing the ARK:Survival Evolved Dedicated Server
    configuration file
"""

import sys
from configparser import RawConfigParser


def save_config(config: RawConfigParser, config_file: str) -> None:
    """
    Saves the server config file
    :param config: Dictionary of the values
    :param config_file: Path to the server config file
    :return: None
    """

    # Overwrite the file value with the new value
    with open(config_file, "w") as file:
        config.write(file, space_around_delimiters=False)


def load_config(config_file: str) -> RawConfigParser:
    """
    Loads the server config file
    :param config_file: Path to the server config file
    :return: ConfigParser Object containing the values
    """

    cp: RawConfigParser = RawConfigParser()
    cp.optionxform = lambda option: option

    if cp.read(config_file) is not None:
        return cp
    else:
        raise TypeError("Config file is invalid!")


def check_server_config_file(config_file: str) -> bool:
    """
    Checks if the server config file exists
    :param config_file: Path to the server config file
    :return: True if the file exists, False if not
    """

    try:
        with open(config_file, "r") as file:
            return True
    except FileNotFoundError:
        sys.stderr.write(f"{config_file} not found!\n")
        return False


if __name__ == "__main__":
    if len(sys.argv) < 4 or len(sys.argv) > 5:
        print("Usage: edit_server_config.py <config_file> <section> <key> [<value>]")
        sys.exit(1)

    config_file: str = sys.argv[1]
    section: str = sys.argv[2]
    key: str = sys.argv[3]

    if check_server_config_file(config_file):
        config: RawConfigParser = load_config(config_file)

        if len(sys.argv) == 4:
            # Return the value of the given key
            if section in config:
                if key in config[section]:
                    print(f"{config[section][key]}")
        else:
            # Assign a new value
            value: str = sys.argv[4]

            # Set the desired value
            config[section][key] = value

            # Save the config file
            save_config(config, config_file)
