#!/bin/bash

packages=()

#set -ex
IMAGES_DATA=$(luet tree images -t $COMMON_TREE --image-repository $REPO_CACHE -t $TREE $PACK -o json)
PKG_LIST=$(luet tree pkglist --tree $TREE --tree=$COMMON_TREE -o json)
images=($(echo $IMAGES_DATA | jq -r '.packages[].image' ))
images_names=($(echo $IMAGES_DATA | jq -r '.packages[].name' ))

echo "For layer $PACK:
previous packages layer: ${images_names[-2]}
after packages layer: ${images_names[-1]}
"

if [[ "${#images[@]}" == "1" ]];then
  packages_before=()
else
  if [ "${images_names[-2]}" == "development/mocaccino-overlay-x" ] ; then
    packages_before=()
  else
    packages_before=( $(docker run --rm ${images[-2]} qlist -ISC) )
  fi
fi
packages_after=( $(docker run --rm ${images[-1]} qlist -ICS) )

IFS=/ read -a p <<< $PACK


path=$(echo "$PKG_LIST" | jq -r ".packages[] | select(.name==\"${p[1]}\" and .category==\"${p[0]}\").path")
for target in "${packages_before[@]}"; do
  for i in "${!packages_after[@]}"; do
    if [[ ${packages_after[i]} = $target ]]; then
      unset 'packages_after[i]'
    fi
  done
done

p=0
for i in ${packages_after[@]};
do

  name=$(pkgs-checker pkg info $i --json | jq '.name' -r)
  cat=$(pkgs-checker pkg info $i --json | jq '.category' -r)
  slot=$(pkgs-checker pkg info $i --json | jq '.slot' -r)
  # Ignore sub-slot for now.
  slot=$(echo "${slot}" | sed 's:/.*::g')

  if [[ "${cat}" == "acct-group" ]] || [[ "${cat}" == "acct-user" ]];then
    continue
  fi

  if [ "$slot" != "0" ] ; then
    cat="${cat}-${slot}"
  fi

  echo "Adding ${cat}/${name} ($i)"

  yq w -i $path/definition.yaml "provides[$p].name" "${name}"
  yq w -i $path/definition.yaml "provides[$p].category" "${cat}"
  yq w -i $path/definition.yaml "provides[$p].version" ">=0"

  p=$((p+1))
done
