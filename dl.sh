
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
#           COPIER REPO
####################################

# Set COPIER REPO's remote origin
if [ -z "$(git -C "${DIR}" remote -v)" ]; then
	echo "Adding ${REMOTE_REPO} to remote"
	git -C "${DIR}" remote add origin "${REMOTE_REPO}"
fi



# Download files( .part*, .sh, .md, etc) from online remote repo
git -C "${DIR}" fetch origin master
git -C "${DIR}" reset --hard origin/master

####################################
#           VAULTS REPO
####################################
# Combine part files
cat "${DIR}/VAULTS.b.gpg.part-"* > "${DIR}/VAULTS.b.gpg"
rm -f "${DIR}/VAULTS.b.gpg.part-"*

# Decrypt gpg file
echo "=== Decrypting ==="
gpg --batch --yes \
    --passphrase "${PASSWORD}" \
    --output "${DIR}/VAULTS.b" \
    --decrypt "${DIR}/VAULTS.b.gpg"
rm -f "${DIR}/VAULTS.b.gpg"


# 
if git -C "${DIR}/../VAULTS" status > /dev/null 2>&1; then
	echo ' ===== git repo EXISTS ====='

    # Update remote origin - pc and phone may have different paths (as DIR is a full path)
    echo '[*] Updating remote origin'
    if [ ! -z "$(git -C "${DIR}/../VAULTS" remote -v)" ]; then
        echo 'PYHAHAHAHAH                   1'
        git -C "${DIR}/../VAULTS" remote remove origin
    fi
    git -C "${DIR}/../VAULTS" remote add origin "${DIR}/VAULTS.b"

    # 
	git -C "${DIR}/../VAULTS" pull "${DIR}/VAULTS.b"
	# git -C "${DIR}/../VAULTS" add -A
	# git -C "${DIR}/../VAULTS" commit --allow-empty-message -m ""
else
	echo ' ===== git repo does NOT exist ===== '
	git -C "${DIR}/../VAULTS" init
	git -C "${DIR}/../VAULTS" remote add origin "${DIR}/VAULTS.b"
	git -C "${DIR}/../VAULTS" fetch origin
	git -C "${DIR}/../VAULTS" checkout -b master origin/master
fi



