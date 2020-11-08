#!/bin/bash
# Generate packages from templates and a list.
# Author: Ettore Di Giacinto
set -ex 
PACKAGE_FILE=$1

# Options
AUTO_GIT="${AUTO_GIT:-false}"
MULTIPLE_PR="${MULTIPLE_PR:-false}"

START_GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
HUB_ARGS="${HUB_ARGS:--b $START_GIT_BRANCH}"

if [ "${AUTO_GIT}" == "true" ]; then
    BRANCH_NAME="create_packages"
    git branch -D $BRANCH_NAME
    git checkout -b $BRANCH_NAME
fi

for i in $(yq r $PACKAGE_FILE 'packages[*].atom'); do
    atom=$i
    PACKAGE_NAME=$(yq r $PACKAGE_FILE "packages(atom==$atom).name")
    PACKAGE_CATEGORY=$(yq r $PACKAGE_FILE "packages(atom==$atom).category")
    PACKAGE_VERSION=$(yq r $PACKAGE_FILE "packages(atom==$atom).version")
    TREE_PATH=$(yq r $PACKAGE_FILE "packages(atom==$atom).path")
    BUILD_TEMPLATE=$(yq r $PACKAGE_FILE "packages(atom==$atom).build_template")
    RUNTIME_REQUIRES=$(yq r $PACKAGE_FILE "packages(atom==$atom).requires.runtime")
    BUILD_REQUIRES=$(yq r $PACKAGE_FILE "packages(atom==$atom).requires.build")

    if [ "${MULTIPLE_PR}" == "true" ]; then
        BRANCH_NAME="create_${PACKAGE_NAME}_${PACKAGE_CATEGORY}"
        if [ "${AUTO_GIT}" == "true" ]; then
            git branch -D $BRANCH_NAME
            git checkout -b $BRANCH_NAME
        fi
    fi

    echo "Package $PACKAGE_NAME"

    mkdir -p $TREE_PATH/$PACKAGE_NAME/
    cp -rfv $BUILD_TEMPLATE $TREE_PATH/$PACKAGE_NAME/build.yaml
    [ -e "$TREE_PATH/$PACKAGE_NAME/definition.yaml" ] && rm -rf $TREE_PATH/$PACKAGE_NAME/definition.yaml
    touch $TREE_PATH/$PACKAGE_NAME/definition.yaml
    yq w -i $TREE_PATH/$PACKAGE_NAME/definition.yaml "category" $PACKAGE_CATEGORY --style double
    yq w -i $TREE_PATH/$PACKAGE_NAME/definition.yaml "name" $PACKAGE_NAME --style double
    yq w -i $TREE_PATH/$PACKAGE_NAME/definition.yaml "version" $PACKAGE_VERSION --style double

    for l in $(yq r packages.yaml -j | jq -r ".packages[] | select(.atom==\"$atom\").labels | keys[]"); do
        k=$(yq r packages.yaml -j | jq -r ".packages[] | select(.atom==\"$atom\").labels | .\"$l\"" | tr " " "\n")
        yq w -i $TREE_PATH/$PACKAGE_NAME/definition.yaml "labels.\"$l\""  --style folded -- "$k"
    done
    
    cat << EOF >> $TREE_PATH/$PACKAGE_NAME/definition.yaml
requires:
$RUNTIME_REQUIRES
EOF

   cat << EOF >> $TREE_PATH/$PACKAGE_NAME/build.yaml
requires:
$BUILD_REQUIRES
EOF

     if [ "${AUTO_GIT}" == "true" ] && [ "${MULTIPLE_PR}" == "true" ]; then
            git add $TREE_PATH/$PACKAGE_NAME/
            git commit -m "Import $PACKAGE_CATEGORY/$PACKAGE_NAME"
            git push -f -v origin $BRANCH_NAME

            # Branch is ready now to open PR
            hub pull-request $HUB_ARGS -m "$(git log -1 --pretty=%B)"

            git checkout $START_GIT_BRANCH # Return to original branch
    fi
done

if [ "${AUTO_GIT}" == "true" ] && [ "${MULTIPLE_PR}" != "true" ]; then
        git push -f -v origin $BRANCH_NAME
        # Branch is ready now to open PR
        hub pull-request $HUB_ARGS -m "$(git log -1 --pretty=%B)"
        git checkout $START_GIT_BRANCH # Return to original branch
fi