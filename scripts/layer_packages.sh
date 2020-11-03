#!/bin/bash
# Returns an array of packages that can be used in definitions from packages in a layer
IMAGE=${1:-mocaccinoos/portage-amd64-cache:a62f6aad5004e3163eb18a5b692881572ccc8300f4e2209825ab58276679e930}

for i in $(docker run --rm $IMAGE qlist -IC);
do
IFS=/ read -a package <<< $i

echo "- name: \"${package[1]}\""
echo "  category: \"${package[0]}\""
echo "  version: \">=0\""

done