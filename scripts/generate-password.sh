#!/bin/bash
# Generate SHA-512 password hash for user sudo/become password
# Usage:
#   ./scripts/generate-password.sh                  # prompt for password
#   ./scripts/generate-password.sh 'mypassword'     # pass directly
#
# After generating, paste the hash into vars/users_passwords.yml:
#   user_passwords:
#     username: "<paste hash here>"
# Then encrypt the file: ansible-vault encrypt vars/users_passwords.yml

set -euo pipefail

if [ $# -ge 1 ]; then
    PASSWORD="$1"
else
    read -s -p "Enter password: " PASSWORD
    echo
    read -s -p "Confirm password: " PASSWORD_CONFIRM
    echo
    if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
        echo "ERROR: Passwords do not match" >&2
        exit 1
    fi
fi

# Generate SHA-512 hash
if command -v mkpasswd &> /dev/null; then
    HASH=$(mkpasswd -m sha-512 "$PASSWORD")
elif command -v openssl &> /dev/null; then
    HASH=$(openssl passwd -6 "$PASSWORD")
else
    echo "ERROR: mkpasswd or openssl required. Install with: apt install whois (for mkpasswd)" >&2
    exit 1
fi

echo "$HASH"
