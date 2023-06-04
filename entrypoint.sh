#!/bin/bash -e

beforeCommand=$1
shouldPublish=$2

runner () {
    echo "🟡 starting $@"
    $@ && echo "🟢 $@ passed" || (echo "🔴 $@ failed" && exit 1)
}

if [[ -n "$GITHUB_WORKSPACE" ]]; then
    git config --global --add safe.directory $GITHUB_WORKSPACE
fi

git config --global user.name ${GITHUB_ACTOR}
git config --global user.email 'autobump@users.noreply.github.com'

export INPUT_REPOSITORY_URL=https://pypi.org
export HATCH_INDEX_USER=__token__
export HATCH_INDEX_AUTH="$(python /app/oidc-exchange.py)"

echo "🟢 HATCH_INDEX_AUTH=$HATCH_INDEX_AUTH"

if [ -n "$(git status --porcelain)" ]; then
    # Working directory clean
    # Uncommitted changes
    echo "🔴 There are uncommitted changes, exiting"
    exit 1
fi

# runner hatch env create

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

    'refs/heads/patch')
        if [[ "$VERSION" == *"dev"* ]]; then
            hatch version dev
        else
            hatch version patch,dev
        fi
        ;;

    *)
        echo "🔵 Skipped Version Bump"
        ;;
esac

NEW_VERSION=`hatch version`


if [ "$VERSION" != "$NEW_VERSION" ] && [ $shouldPublish == true ]; then
    echo "🟢 Success: bump version: $VERSION → $NEW_VERSION"

    git add .
    git commit -m "Bump version: $VERSION → $NEW_VERSION"
    git tag v$NEW_VERSION
    git remote -v

    echo "🟢 Success version push"

    runner hatch build
    runner hatch publish

    git push
    git push --tags
    runner gh release create v$NEW_VERSION -F CHANGELOG.md dist/*.whl dist/*.tar.gz
    runner echo "release is complete"

else
    echo "🔵 Skipped Publish"
fi


exit 0
