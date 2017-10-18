#!/usr/bin/env bash

# this shell script updates the ssh keys in ~/.ssh/known_hosts
# for all hosts or for a group in the given inventory
# invoke as follows:
#
# ./update-known-hosts.sh <env/inv>...    - update ssh keys for the given environments/inventories

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

if [ -z "$1" ]; then
  echo -e "$ERR"target environment/inventory not set"$END"
  exit 1
fi


ARGS=()
while [ -n "$1" ]; do
  key="$1"

  case $key in
    -d|--dryrun)
    DRY_RUN=true
    ;;
    *)    # unknown option
    ARGS+=("$1") # save it in an array for later
    shift # past argument
    ;;
  esac
done
set -- "${ARGS[@]}" # restore positional parameters

while [ -n "$1" ]; do
  if [ -f "$1" ]; then
    INVENTORY="$1"
  elif [ -f "env/$1/inventory" ]; then
    INVENTORY="env/$1/inventory"
  else
    echo -e "$ERR"target environment/inventory "$1" not found"$END"
    exit 1
  fi
  shift

  echo -e "$CMD"'> $ 'ansible-playbook ansible/update-known-hosts.yml -i "$INVENTORY" "$@""$END"
  if [ -z "$DRY_RUN" ]; then
    ansible-playbook ansible/update-known-hosts.yml -i "$INVENTORY" "$@"
  fi
done
