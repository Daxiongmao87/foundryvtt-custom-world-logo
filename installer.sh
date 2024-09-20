#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
CUSTOM_LOGO_START="<!-- Custom Logo Script Start -->"
CUSTOM_LOGO_END="<!-- Custom Logo Script End -->"
CUSTOM_LOGO_VERSION_TAG="<!-- Custom Logo Script Version:"
JOIN_GAME_RELATIVE_PATH="resources/app/templates/setup/join-game.hbs"
SCRIPT_NAME=$(basename "$0")

# Help function
function show_help() {
    echo "Usage: $SCRIPT_NAME [-y] [install|uninstall] <foundry_root_path>"
    echo "Options:"
    echo "  -y                Bypass confirmation prompts"
    echo "Commands:"
    echo "  install           Install the custom logo script"
    echo "  uninstall         Uninstall the custom logo script"
    exit 1
}

# Initialize variables
YES_FLAG=false

# Parse options
while getopts ":y" opt; do
    case ${opt} in
        y )
            YES_FLAG=true
            ;;
        \? )
            echo "Invalid option: -$OPTARG" >&2
            show_help
            ;;
    esac
done
shift $((OPTIND -1))

# Check for required arguments
if [ "$#" -lt 2 ]; then
    show_help
fi

MODE=$1
FOUNDRY_ROOT=$2

JOIN_GAME_FILE="$FOUNDRY_ROOT/$JOIN_GAME_RELATIVE_PATH"

# Check if join-game.hbs exists
if [ ! -f "$JOIN_GAME_FILE" ]; then
    echo "Error: File '$JOIN_GAME_FILE' not found."
    exit 1
fi

# Check if custom-logo-script.html exists
if [ ! -f "custom-logo-script.html" ]; then
    echo "Error: 'custom-logo-script.html' not found in the current directory."
    exit 1
fi

# Read custom logo script
CUSTOM_LOGO_SCRIPT=$(<custom-logo-script.html)

# Extract version from custom-logo-script.html
CUSTOM_LOGO_VERSION=$(echo "$CUSTOM_LOGO_SCRIPT" | grep "$CUSTOM_LOGO_VERSION_TAG" | sed 's/.*Version: \([0-9.]*\).*-->/\1/')
if [ -z "$CUSTOM_LOGO_VERSION" ]; then
    echo "Error: Could not extract version from 'custom-logo-script.html'."
    exit 1
fi

# Function to install custom logo script
function install_script() {
    # Check if custom script is already installed
    if grep -qF "$CUSTOM_LOGO_START" "$JOIN_GAME_FILE"; then
        CURRENT_VERSION=$(grep -F "$CUSTOM_LOGO_VERSION_TAG" "$JOIN_GAME_FILE" | sed 's/.*Version: \([0-9.]*\).*-->/\1/')
        if [ -z "$CURRENT_VERSION" ]; then
            CURRENT_VERSION="unknown"
        fi
	        # Compare current and installer versions
        if [ "$(printf '%s\n' "$CURRENT_VERSION" "$CUSTOM_LOGO_VERSION" | sort -V | head -n1)" == "$CUSTOM_LOGO_VERSION" ] && [ "$CURRENT_VERSION" != "$CUSTOM_LOGO_VERSION" ]; then
            # Installed version is greater than the version in the installer
            if [ "$YES_FLAG" = false ]; then
                read -p "A newer version of the custom logo script is already installed (version $CURRENT_VERSION). Do you want to downgrade to version $CUSTOM_LOGO_VERSION? (y/n): " CONFIRM
                if [[ "$CONFIRM" != "y" ]]; then
                    echo "Downgrade canceled."
                    exit 0
                fi
            fi
            echo "Downgrading the custom logo script to version $CUSTOM_LOGO_VERSION..."
            cp "$JOIN_GAME_FILE" "$JOIN_GAME_FILE.bak"
            sed_command
            echo "$CUSTOM_LOGO_SCRIPT" | cat - "$JOIN_GAME_FILE" > temp && mv temp "$JOIN_GAME_FILE"
            echo "Custom logo script downgraded to version $CUSTOM_LOGO_VERSION."
        elif [ "$CURRENT_VERSION" == "$CUSTOM_LOGO_VERSION" ]; then
            echo "Custom logo script is already installed with the latest version ($CUSTOM_LOGO_VERSION)."
            exit 0
        else
            # Installed version is lower than the version in the installer
            if [ "$YES_FLAG" = false ]; then
                read -p "An older version of the custom logo script is installed (version $CURRENT_VERSION). Do you want to update to version $CUSTOM_LOGO_VERSION? (y/n): " CONFIRM
                if [[ "$CONFIRM" != "y" ]]; then
                    echo "Update canceled."
                    exit 0
                fi
            fi
            echo "Updating the custom logo script to version $CUSTOM_LOGO_VERSION..."
            cp "$JOIN_GAME_FILE" "$JOIN_GAME_FILE.bak"
            sed_command
            echo "$CUSTOM_LOGO_SCRIPT" | cat - "$JOIN_GAME_FILE" > temp && mv temp "$JOIN_GAME_FILE"
            echo "Custom logo script updated to version $CUSTOM_LOGO_VERSION."
        fi
    else
        if [ "$YES_FLAG" = false ]; then
            read -p "Custom logo script not found. Do you want to install it? (y/n): " CONFIRM
            if [[ "$CONFIRM" != "y" ]]; then
                echo "Installation canceled."
                exit 0
            fi
        fi
        echo "Installing custom logo script (version $CUSTOM_LOGO_VERSION)..."
        # Create a backup
        cp "$JOIN_GAME_FILE" "$JOIN_GAME_FILE.bak"
        # Prepend the custom logo script to join-game.hbs
        echo "$CUSTOM_LOGO_SCRIPT" | cat - "$JOIN_GAME_FILE" > temp && mv temp "$JOIN_GAME_FILE"
        echo "Custom logo script installed successfully."
    fi
}

# Function to uninstall custom logo script
function uninstall_script() {
    if grep -qF "$CUSTOM_LOGO_START" "$JOIN_GAME_FILE"; then
        if [ "$YES_FLAG" = false ]; then
            read -p "Custom logo script found. Do you want to uninstall it? (y/n): " CONFIRM
            if [[ "$CONFIRM" != "y" ]]; then
                echo "Uninstallation canceled."
                exit 0
            fi
        fi
        echo "Uninstalling the custom logo script..."
        # Create a backup
        cp "$JOIN_GAME_FILE" "$JOIN_GAME_FILE.bak"
        # Remove the custom logo script block
        sed_command
        echo "Custom logo script uninstalled successfully."
    else
        echo "Custom logo script is not installed."
    fi
}

# Function to execute sed command in a portable way
function sed_command() {
    # Escape slashes in the patterns
    ESCAPED_START=$(printf '%s\n' "$CUSTOM_LOGO_START" | sed 's/[[\.*^$/]/\\&/g')
    ESCAPED_END=$(printf '%s\n' "$CUSTOM_LOGO_END" | sed 's/[[\.*^$/]/\\&/g')
    # Use different sed syntax for macOS and Linux
    if sed --version >/dev/null 2>&1; then
        # GNU sed
        sed -i "/$ESCAPED_START/,/$ESCAPED_END/d" "$JOIN_GAME_FILE"
    else
        # BSD sed (macOS)
        sed -i '' "/$ESCAPED_START/,/$ESCAPED_END/d" "$JOIN_GAME_FILE"
    fi
}

# Main logic
case $MODE in
    install)
        install_script
        ;;
    uninstall)
        uninstall_script
        ;;
    *)
        echo "Error: Invalid command '$MODE'."
        show_help
        ;;
esac

