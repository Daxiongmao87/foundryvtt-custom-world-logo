# Custom Logo Script Installer for Foundry VTT

This project provides an easy way to install, update, or uninstall a custom logo script for Foundry VTT. The script allows you to inject a custom logo into your "Join Game" screen and customize its appearance via the `alt` text.

## Installation Options

There are two ways to install or uninstall the custom logo script:

1. Using the `installer.sh` script (recommended).
2. Manual installation.

---

## 1. Installation via `installer.sh` (Recommended)

The `installer.sh` script automates the process of installing, updating, or uninstalling the custom logo script in Foundry VTT.

### Prerequisites

- Linux, unfortunately there is no Windows version of the install script yet.
- Foundry Virtual Tabletop installed
- The `custom-logo-script.html` and `installer.sh` in this repository.

### Usage

```bash
# To install the custom logo script
./installer.sh install /path/to/foundryvtt

# To uninstall the custom logo script
./installer.sh uninstall /path/to/foundryvtt

# To bypass confirmation prompts
./installer.sh -y install /path/to/foundryvtt
```

### Explanation

- **Install**: Installs or updates the custom logo script. If a previous version of the script is detected, the script prompts for an update (unless `-y` is used).
- **Uninstall**: Removes the custom logo script from the `join-game.hbs` file.
- **`-y` flag**: Skips confirmation prompts, useful for automated installs/updates.

---

## 2. Manual Installation

If you prefer, you can manually add the custom logo script to the `join-game.hbs` file.

### Steps

1. Locate the `join-game.hbs` file in your Foundry VTT instance:

   ```bash
   /path/to/foundryvtt/resources/app/templates/setup/join-game.hbs
   ```

2. Open the `join-game.hbs` file in a text editor.

3. Open the `custom-logo-script.html` file, copy its contents, and paste them at the **very top** of `join-game.hbs`.

4. Save and close the file.

### Example

If you are using `nano` as a text editor:

```bash
nano /path/to/foundryvtt/resources/app/templates/setup/join-game.hbs
```

Paste the contents of `custom-logo-script.html` at the top of the file, then save it by pressing `CTRL + O`, and exit by pressing `CTRL + X`.

### Removing the Script (Manual Uninstall)

1. Open the `join-game.hbs` file:

   ```bash
   nano /path/to/foundryvtt/resources/app/templates/setup/join-game.hbs
   ```

2. Search for the custom logo script section, which is wrapped with these comments:

   ```html
   <!-- Custom Logo Script Start -->
   <!-- Custom Logo Script End -->
   ```

3. Remove the entire block of code between `<!-- Custom Logo Script Start -->` and `<!-- Custom Logo Script End -->`, including those comment lines.

4. Save the file and exit.

---

## Troubleshooting

- If you encounter issues, ensure you have appropriate permissions to edit the `join-game.hbs` file.
- Make sure both `custom-logo-script.html` and `installer.sh` are placed in the same directory when using the installer.
- Make sure installer.sh has the executable flag set (`chmod +x installer.sh`).
