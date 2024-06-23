#!/bin/bash
# set -euo pipefail # No need, acme-sh exit code 2 is a normal case
set -a # export all

# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p "${SCRIPT_DIR}"/data

echo "" > "${SCRIPT_DIR}"/data/acme.sh.log

echo "Generating certificate for:"

##  Naming certs https://community.letsencrypt.org/t/difference-between-pem-and-crt-and-how-to-use-them/179161/2

echo "${SCRIPT_DIR}";

REQUEST_STRING=""

while read line
do
    DOMAIN=$line
    echo "${DOMAIN}"
    REQUEST_STRING="${REQUEST_STRING} \
-d ${DOMAIN} --challenge-alias acme-challenges.uuusoftware.com --dns dns_cloudns"
done < "${SCRIPT_DIR}/../.domains.txt"

docker run --rm  \
  --name=acme.sh \
  --mount type=bind,source="${SCRIPT_DIR}"/..,target=/certs \
  --mount type=bind,source="${SCRIPT_DIR}"/data,target=/acme.sh \
  -e CLOUDNS_AUTH_ID=22011 \
  -e CLOUDNS_SUB_AUTH_ID='' \
  -e CLOUDNS_AUTH_PASSWORD="213213125676543" \
  neilpang/acme.sh \
    --issue \
    --debug 0 \
    --dnssleep 600 \
    --log \
    --server letsencrypt \
    --cert-file "/certs/cert.pem" \
    --ca-file "/certs/chain.pem" \
    --fullchain-file "/certs/fullchain.pem" \
    --key-file "/certs/privkey.pem" \
    ${REQUEST_STRING}

# acme.sh exited with code 2 when no updates needed

RENEW_EXIT_CODE=$?

if [ ${RENEW_EXIT_CODE} -eq 0 ]; then
  echo "Successfully updated"
  exit 0
elif [ ${RENEW_EXIT_CODE} -eq 2 ]; then
  echo "Update not needed, exit."
  exit 0
else
  echo "Script got Fail" >&2
  exit ${RENEW_EXIT_CODE}
fi
