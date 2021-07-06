#!/bin/bash

function download_terraform() {
  local ver="$1"
  local dest="$2"

  local ostype=$(get_ostype)
  dl_url=https://releases.hashicorp.com/terraform/${ver}/terraform_${ver}_${ostype}_amd64.zip

  tmpfile="${BUILDKITE_BUILD_CHECKOUT_PATH}/.terraform-download.zip"
  if ! curl -sL -o $tmpfile --fail $dl_url; then
    >&2 echo -e "${RED}ERROR: Failed to download terraform from $dl_url${NC}"
    return 1
  fi

  # extract into temp place
  unzip -q -n $tmpfile -d "${BUILDKITE_BUILD_CHECKOUT_PATH}/.terraform-dl/"
  # move to final dest
  mkdir -p $(dirname $dest)
  mv ${BUILDKITE_BUILD_CHECKOUT_PATH}/.terraform-dl/terraform $dest
}

function get_ostype() {
  if [[ "$OSTYPE" == "linux"* ]]; then
    echo "linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "darwin"
  else
    >&2 echo -e "${RED}ERROR: Cannot determine os type from '$OSTYPE'${NC}"
    return 1
  fi
}

