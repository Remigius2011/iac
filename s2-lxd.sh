#!/usr/bin/env bash

# this shell script configures a set of lxd hosts
# it executes the playbook lxd-hosts.yml on the given inventory
# and adjusts the management host accordingly (routes etc.) by executing
# the playbook lxd-clients.yml on the management host
# it is assumed that the hosts are already prepared for ansible
# otherwise execute the script prepare-for-ansible first for the hosts
#
# invoke as follows:
#
# ./step2-lxd.sh                   - configure LXD hosts with default LXD and MGT environments/inventories
# ./step2-lxd.sh <lxd>             - configure LXD hosts with given LXD and default MGT environments/inventories
# ./step2-lxd.sh <lxd> <mgt>       - configure LXD hosts with given LXD and MGT environments/inventories
#
# add -c as first argument to skip host configuration and configure the mgt environment only
#
# ./step2-lxd.sh -c                - adjust management hosts with default LXD and MGT environments/inventories
# ./step2-lxd.sh -c <lxd> <mgt>    - adjust management hosts with given LXD and MGT environments/inventories

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
    -d)       DRY_RUN=true; echo -e "${WRN}*** DRY RUN ***${END}"; shift;;
    -c)       CLIENT_ONLY=true; echo -e "${WRN}*** CLIENT ONLY ***${END}"; shift;;
    -cd|-dc)  DRY_RUN=true; CLIENT_ONLY=true; echo -e "${WRN}*** DRY RUN ***\n*** CLIENT ONLY ***${END}"; shift;;
    *)        ARGUMENTS+=("$1"); shift;;
  esac
done
set -- "${ARGUMENTS[@]}"

if [ -n "$1" ]; then
  if [ -f "$1" ]; then
    LXD_INVENTORY="$1"
  elif [ -f "env/$1/host-inventory" ]; then
    LXD_INVENTORY="env/$1/host-inventory"
  else
    echo -e "$ERR"target environment/inventory "$1" not found"$END"
    exit 1
  fi
  shift
else
  LXD_INVENTORY="env/lxd/host-inventory"
fi

if [ -n "$1" ]; then
  if [ -f "$1" ]; then
    MGT_INVENTORY="$1"
  elif [ -f "env/$1/inventory" ]; then
    MGT_INVENTORY="env/$1/inventory"
  else
    echo -e "$ERR"target environment/inventory "$1" not found"$END"
    exit 1
  fi
  shift
else
  MGT_INVENTORY="env/mgt/inventory"
fi

if [ -z "$CLIENT_ONLY" ]; then
  echo -e "$CMD"'> $ 'ansible-playbook ansible/lxd-hosts.yml -i "$LXD_INVENTORY""$END"
  if [ -z "$DRY_RUN" ]; then
    ansible-playbook ansible/lxd-hosts.yml -i "$LXD_INVENTORY"
  fi
else
  echo -e "$INF"host configuration skipped"$END"
fi

LXD_DIR=$(dirname "$LXD_INVENTORY")

VAR_PARAMS=
if [ -d "$LXD_DIR/group_vars/all" ]; then
  for file in "$LXD_DIR/group_vars/all"/*; do
    VAR_PARAMS="$VAR_PARAMS -e @$file"
  done
elif [ -f "$LXD_DIR/group_vars/all" ]; then
  VAR_PARAMS="-e @$LXD_DIR/group_vars/all"
elif [ -f "$LXD_DIR/group_vars/all.yml" ]; then
  VAR_PARAMS="-e @$LXD_DIR/group_vars/all.yml"
elif [ -f "$LXD_DIR/group_vars/all.yaml" ]; then
  VAR_PARAMS="-e @$LXD_DIR/group_vars/all.yaml"
fi

echo -e "$CMD"'> $ 'ansible-playbook ansible/lxd-clients.yml -i "$MGT_INVENTORY" $VAR_PARAMS "$@""$END"
if [ -z "$DRY_RUN" ]; then
  ansible-playbook ansible/lxd-clients.yml -i "$MGT_INVENTORY" $VAR_PARAMS "$@"
fi
