# Folder structure:
You must have a similar folder structure as shown below.
The `VAULTS` folder is where you place all your obsidian vaults.
```
/
    - COPIER/
        - .env
        - up.sh
        - dl.sh
        - README.MD
        - .gitignore
        - .git/
    - VAULTS/
```


# Environment Variable File (.env):
Your environment variable file should look something like the below. Make sure to set the password to something secure
```
REMOTE_REPO=git@github.com:slooi/_OBSIDIAN
PASSWORD=password
```

WARNING:
- make sure the PASSWORD is the same across all your devices!!! The PASSWORD is used for both encryption and decryption