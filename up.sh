: "
ASSUMPTIONS:


Folder structure:
_OBSIDIAN/
    - COPIER/
        - .env
        - up.sh
        - dl.sh
        - README.MD
        - .gitignore
        - .git/
    - VAULTS/


Environment Variable File (.env):
REMOTE_REPO=git@github.com:slooi/_OBSIDIAN
PASSWORD=password

WARNING:
- make sure the PASSWORD is the same across all your devices!!! Otherwise you won't be able to decrypt it!

"

####################################
####################################
# INITALIZATION
####################################
####################################

echo '[*] Initalizing environment variables...'

# Get directory path
DIR="$(dirname "$(readlink -f "$0")")"
echo "DIR=${DIR}"
echo ""

# Load environment variables from .env (loads PASSWORD and REMOTE_REPO)
if [ -f "${DIR}/.env" ]; then
    echo '[*] Loading .env file'
    source "${DIR}/.env" 
        
    # Validate environment variables loaded corrected
    if [ -z "${REMOTE_REPO}" ]; then
        echo '      !!! ERROR: Environment variable `REMOTE_REPO` NOT found inside .env file!'
        read
        exit 1
    fi
    if [ -z "${PASSWORD}" ]; then
        echo '      !!! ERROR: Environment variable `PASSWORD` NOT found inside .env file!'
        read
        exit 1
    fi
else
    echo '      !!! ERROR: .env file does NOT exist!'
    read
    exit 1
fi

echo '[*] All environment variables loaded successfully'

####################################
####################################
# MAIN CODE
####################################
####################################


####################################
#           VAULTS REPO
####################################
# Commit changes
git -C "${DIR}/../VAULTS" add -A
git -C "${DIR}/../VAULTS" commit --allow-empty-message -m ""

# Turn vault into a bundle file (.b)
git -C "${DIR}/../VAULTS" bundle create "${DIR}/VAULTS.b" --all

# Encrypt bundle file into gpg file
gpg --batch --yes --passphrase "${PASSWORD}" --symmetric "${DIR}/VAULTS.b"
rm -f "${DIR}/VAULTS.b"

# Split gpg file into <80MB chunks
rm -f "${DIR}/VAULTS.b.gpg.part-"* # remove parts from old upload. otherwise can corrupt concat file
split -b 80M "${DIR}/VAULTS.b.gpg" "${DIR}/VAULTS.b.gpg.part-"
rm -f "${DIR}/VAULTS.b.gpg" 

echo '[*] Finished encrypting and splitting files'

####################################
#           COPIER REPO
####################################

# Create git COPIER REPO if it doesn't exist
if ! git -C "${DIR}" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "      !!! WARNING: Repo does NOT exist. Auto initializing repo"
    git -C "${DIR}" init
fi
# Set COPIER REPO's remote origin
if [ -z "$(git -C "${DIR}" remote -v)" ]; then
	echo "Adding ${REMOTE_REPO} to remote"
	git -C "${DIR}" remote add origin "${REMOTE_REPO}"
fi

echo '[*] Finished potential COPIER REPO initialization'

# Commit files ( .part, .sh, .md, etc) to COPIER REPO
git -C "${DIR}" add -A
git -C "${DIR}" commit --allow-empty-message -m "" 

# Merge all commits into one singular commit
GIT_SEQUENCE_EDITOR="sed -i -e '2,\$s/^pick/f/'" git -C "${DIR}" rebase -i --root

# Set COPIER REPO's remote repo & push to remote repo
if [ -z "$(git -C "${DIR}" remote -v)" ]; then
	echo "Adding ${REMOTE_REPO} to remote"
	git -C "${DIR}" remote add origin "${REMOTE_REPO}"
fi
git -C "${DIR}" push -f -u origin master