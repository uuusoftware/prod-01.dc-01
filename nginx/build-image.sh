# shellcheck disable=SC1101
docker build . \
  --tag ms-site:local \
  --squash
