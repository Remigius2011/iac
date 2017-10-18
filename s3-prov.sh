#!/usr/bin/env bash

# this shell script provisions docker hosts (containers/cloud vms)
# it executes terraform and writes the terraform output (inventory and json files) to the root directory
# invoke as follows:
#
# ./step3-prov.sh <env>         - provisions docker hosts for the given environment (do/lxd/...)
# ./step3-prov.sh <env> <op>    - executes the given terraform command (plan/destroy) for the given environment (do/lxd/...)

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
  TARGET_ENV=$1
  shift
else
    echo -e "$ERR"target environment/inventory not set"$END"
  exit 1
fi

if [ -n "$1" ]; then
  TERRAFORM_OP=$1
  shift
else
  TERRAFORM_OP=apply
fi

export TF_VAR_management_user="$(ansible-vault view ansible-vault | grep management_user | cut -f 2 -d ' ')"
export TF_VAR_management_password="$(ansible-vault view ansible-vault | grep ansible_ssh_pass | cut -f 2 -d ' ')"
export TF_VAR_do_api_token="$(ansible-vault view ansible-vault | grep digitalocean_api_token | cut -f 2 -d ' ')"
export TF_VAR_do_key_fingerprint="$(ansible-vault view ansible-vault | grep digitalocean_key_fingerprint | cut -f 2 -d ' ')"

CURRENT_DIR=$(pwd)
echo -e "$CMD"'> $ 'cd "env/$TARGET_ENV/tf""$END"
cd "env/$TARGET_ENV/tf"

if [ "$TERRAFORM_OP" != "destroy" ]; then
  echo -e "$CMD"'> $ 'terraform init"$END"
  if [ -z "$DRY_RUN" ]; then
    terraform init
  fi
fi

echo -e "$CMD"'> $ 'terraform "$TERRAFORM_OP" "$@""$END"
if [ -z "$DRY_RUN" ]; then
  terraform "$TERRAFORM_OP" "$@"
fi

if [ "$TERRAFORM_OP" != "destroy" ]; then
  echo -e "$CMD"'> $ 'terraform output inventory-json > "../inventory.json""$END"
  if [ -z "$DRY_RUN" ]; then
    terraform output inventory-json > "../inventory.json"
  fi
fi

echo -e "$CMD"'> $ 'cd "$CURRENT_DIR""$END"
cd "$CURRENT_DIR"

# feed inventory json to some jq files - see also https://stedolan.github.io/jq/
# for each jq file in the jq directory, the .jq extension is stripped go get the filename
# and the resulting output is saved in the $TARGET_ENV subdirectory

if [ "$TERRAFORM_OP" != "destroy" ]; then
  if [ -d "jq" ]; then
    echo -e "$INF"process generic jq files"$END"
    for file in jq/*.jq; do
      echo -e "$CMD"'> $ 'cat "env/$TARGET_ENV/inventory.json" | jq -fr "$file" > "env/$TARGET_ENV/$(basename "$file" .jq | tr '#' '/')""$END"
      cat "env/$TARGET_ENV/inventory.json" | jq -fr "$file" > "env/$TARGET_ENV/$(basename "$file" .jq | tr '#' '/')"
    done
  fi

  if [ -d "env/$TARGET_ENV/jq" ]; then
    echo -e "$INF"process jq files for env "$TARGET_ENV""$END"
    for file in "$TARGET_ENV/jq"/*.jq; do
      echo -e "$CMD"'> $ 'cat "env/$TARGET_ENV/inventory.json" | jq -fr "$file" > "env/$TARGET_ENV/$(basename "$file" .jq | tr '#' '/')""$END"
      cat "env/$TARGET_ENV/inventory.json" | jq -fr "$file" > "env/$TARGET_ENV/$(basename "$file" .jq | tr '#' '/')"
    done
  fi
fi

echo -e "$CMD"'> $ 'ansible-playbook ansible/update-known-hosts.yml -i "env/$TARGET_ENV/inventory""$END"
if [ -z "$DRY_RUN" ]; then
  ansible-playbook ansible/update-known-hosts.yml -i "env/$TARGET_ENV/inventory"
fi
