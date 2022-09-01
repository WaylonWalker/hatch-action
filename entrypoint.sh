#!/bin/bash

git config --global --add safe.directory $GITHUB_WORKSPACE
git config --global user.name 'autobump'
git config --global user.email 'autobump@users.noreply.github.com'

if [ -n "$(git status --porcelain)" ]; then 
  # Working directory clean
  # Uncommitted changes
  echo "There are uncommitted changes, exiting"
  exit 1
fi


VERSION=`hatch version`

case $GITHUB_REF in

    'refs/heads/main')
        hatch version release
    ;;
    'refs/heads/master')
        hatch version release
    ;;
    'refs/heads/release')
        hatch version release
    ;;

    'refs/heads/alpha')
        hatch version 
        if [[ "$VERSION" == *"a"* ]]; then
            hatch version alpha
        else
            hatch version minor,alpha
        fi
    ;;

    'refs/heads/beta')
        if [[ "$VERSION" == *"b"* ]]; then
            hatch version beta
        else
            hatch version minor,beta
        fi
    ;;

    'refs/heads/dev')
        if [[ "$VERSION" == *"dev"* ]]; then
            hatch version dev
        else
            hatch version minor,dev
        fi
    ;;

    'refs/heads/develop')
        if [[ "$VERSION" == *"dev"* ]]; then
            hatch version dev
        else
            hatch version minor,dev
        fi
    ;;
esac

NEW_VERSION=`hatch version`

git add .
git commit -m "Bump version: $VERSION → $NEW_VERSION"
git tag $VERSION
git push
git push --tags

hatch publish

exit 0
