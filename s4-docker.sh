#!/usr/bin/env bash

# this shell script configures docker hosts on the given environment (bare/do/lxd/...)
# it executes the playbooks docker.yml and swarm.yml
# it is assumed that the hosts in the inventory are prepared for ansible during provisioning
# invoke as follows:
#
# ./step4-docker.sh <env>         - setup docker for the given environment
# ./step4-docker.sh <inventory>   - setup docker for the given inventory

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
  echo -e "$ERR"target environment/inventory not set"$END"
  exit 1
fi

echo -e "$CMD"'> $ 'ansible-playbook ansible/docker.yml -i "$INVENTORY" "$@""$END"
if [ -z "$DRY_RUN" ]; then
  ansible-playbook ansible/docker.yml -i "$INVENTORY" "$@"
fi
