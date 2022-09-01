#!/bin/bash -e

beforeCommand=$1
shouldPublish=$2

runner () {
    echo "🟡 starting $@"
    $@ && echo "🟢 $@ passed" || echo "🔴 $@ failed"
}

git config --global --add safe.directory $GITHUB_WORKSPACE
git config --global user.name 'autobump'
git config --global user.email 'autobump@users.noreply.github.com'

if [ -n "$(git status --porcelain)" ]; then 
  # Working directory clean
  # Uncommitted changes
  echo "There are uncommitted changes, exiting"
  exit 1
fi

runner hatch env create

runner hatch run $beforeCommand

# remove any files such as .coverage
git reset --hard

echo "🟢 beforeCommand success"

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
echo "🟢 Success: bump version: $VERSION → $NEW_VERSION"

if [ "$VERSION" != "$NEW_VERSION" ] && [ $shouldPublish == true ]; then

    git add .
    git commit -m "Bump version: $VERSION → $NEW_VERSION"
    git tag $VERSION
    git push
    git push --tags

    echo "🟢 Success version push"

    runner hatch build
    runner hatch publish

fi

exit 0
