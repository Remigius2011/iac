#!/usr/bin/env bash

# this shell script configures the management host
# it executes the playbook mgmt.yml on the host
# it is assumed that the host is already prepared for ansible
# otherwise execute the script prepare-for-ansible first for the host
#
# invoke as follows:
#
# ./step1-mgt.sh              - configure mgt host with default environment mgt
# ./step1-mgt.sh <env>        - configure mgt host with given environment
# ./step1-mgt.sh <inventory>  - configure mgt host with given inventory

if [ -t 1 ]; then
  N_COLORS=$(tput colors)
  if [ -n "$N_COLORS" -a "$N_COLORS" -ge 8 ]; then
    # colors: CMD: light cyan, INF: green, WRN: yellow, ERR: red
    CMD='\033[1;36m'
    INF='\033[0;32m'
    WRN='\033[1;33m'
    ERR='\033[0;31m'
    END='\033[0m'
  fi
fi

ARGUMENTS=()
while [ -n "$1" ]; do
  key="$1"
  case $key in
    -d) DRY_RUN=true; echo -e "${WRN}*** DRY RUN ***${END}"; shift;;
    *)  ARGUMENTS+=("$1"); shift;;
  esac
done
set -- "${ARGUMENTS[@]}"

if [ -n "$1" ]; then
  if [ -f "$1" ]; then
    INVENTORY="$1"
  elif [ -f "env/$1/inventory" ]; then
    INVENTORY="env/$1/inventory"
  else
    echo -e "$ERR"target environment/inventory "$1" not found"$END"
    exit 1
  fi
  shift
else
  INVENTORY="env/mgt/inventory"
fi

echo -e "$CMD"'> $ 'ansible-playbook ansible/mgmt.yml -i "$INVENTORY" "$@""$END"
if [ -z "$DRY_RUN" ]; then
  ansible-playbook ansible/mgmt.yml -i "$INVENTORY" "$@"
fi
