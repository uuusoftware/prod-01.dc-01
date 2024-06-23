#!/usr/bin/env bash

# set -euo pipefail # No need, acme-sh exit code 2 is a normal case
set -a # export all

# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

"${SCRIPT_DIR}/certificate/.updater/get-certs.bash"
