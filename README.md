## Installation / Setup (Lidarr)

### 1. Add required volumes

Make sure you mount two separate folders (do **NOT** use the same folder for both):

-v /path/to/local/folder-01:/custom-services.d \
-v /path/to/local/folder-02:/custom-cont-init.d

### 2. Download the initialization script

Download the setup script into your custom-cont-init.d folder:

curl -o /path/to/local/folder-02/scripts_init.bash \
https://raw.githubusercontent.com/Kickala/kickarr/main/Lidarr/scripts_init.bash

### 3. Make the script executable
chmod +x /path/to/local/folder-02/scripts_init.bash

### 4. Start the container

Start (or restart) your Lidarr container and wait for it to fully initialize.

### 5. Restart the container a second time after fully initializing.
