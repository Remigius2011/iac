#!/usr/bin/env bash

# this shell script initializes a host for ansible
# first, it adds the host's ssh key to the known hosts file
# then it executes the playbook init-ansible.yml on the host
# invoke as follows:
#
# ./prepare-for-ansible.sh                - update ssh keys and install python for mgt environment
# ./prepare-for-ansible.sh <env/inv>...   - update ssh keys and install python for the given environments/inventories

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
  ARG="$1"
else
  ARG="mgt"
fi

while [ -n "$ARG" ]; do
  if [ -f "$ARG" ]; then
    INVENTORY="$ARG"
  elif [ -f "env/$ARG/inventory" ]; then
    INVENTORY="env/$ARG/inventory"
  else
    echo -e "$ERR"target environment/inventory "$1" not found"$END"
    exit 1
  fi
  shift
  ARG="$1"

  echo -e "$CMD"'> $ 'ansible-playbook ansible/update-known-hosts.yml -i "$INVENTORY""$END"
  if [ -z "$DRY_RUN" ]; then
    ansible-playbook ansible/update-known-hosts.yml -i "$INVENTORY"
  fi
  echo -e "$CMD"'> $ 'ansible-playbook ansible/init-ansible.yml -i "$INVENTORY""$END"
  if [ -z "$DRY_RUN" ]; then
    ansible-playbook ansible/init-ansible.yml -i "$INVENTORY"
  fi
done
