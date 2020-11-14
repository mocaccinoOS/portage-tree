#!/bin/bash

PKG_LIST=$(luet tree pkglist --tree $TREE --tree=$COMMON_TREE -o json)

for i in $(echo "$PKG_LIST" | jq -r '.packages[].path'); do
    PACKAGE_PATH=$i
    PACKAGE_NAME=$(echo "$PKG_LIST" | jq -r ".packages[] | select(.path==\"$i\").name")
    PACKAGE_CATEGORY=$(echo "$PKG_LIST" | jq -r ".packages[] | select(.path==\"$i\").category")
    PACKAGE_VERSION=$(echo "$PKG_LIST" | jq -r ".packages[] | select(.path==\"$i\").version")
    PACK=$PACKAGE_CATEGORY/$PACKAGE_NAME make gen-provides
done
