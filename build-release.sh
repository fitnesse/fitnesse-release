#!/bin/bash

VERSION=`date +%Y%m%d`
EDITOR=vi


function isokay() {
    local ok
    echo "$* (y/N)"
    read ok
    test "x$ok" == "xy"
}

function die() {
    echo "$*"
    exit 1
}

export EDITOR

(cd fitnesse && git pull origin master) || die "Can not update submodule fitnesse"
(cd fitnessedotorg && git pull origin master) || die "Can not update submodule fitnessedotorg"

echo "Releasing $VERSION."

isokay "Is all cruft removed from the frontpage?" || exit
isokay "Is the ReleaseNotes page up to date?" || exit

(cd fitnesse && git status) && isokay "Is okay?" || exit

(cd fitnesse && ./gradlew clean && ./gradlew sign publish -x test) || exit

isokay "Is the distro okay?" || exit

(cd fitnesse && ./gradlew release -x test) || exit

echo "Copying fitnesse-standalone.jar to fitnesse.org"
mkdir fitnessedotorg/releases/$VERSION
cp fitnesse/build/libs/fitnesse-$VERSION-standalone.jar fitnessedotorg/releases/$VERSION/fitnesse-standalone.jar || die "Can not copy fitnesse-standalone.jar"

echo "Setup fitnesse.org to use $VERSION"
cp fitnessedotorg/base.ivy.xml fitnessedotorg/ivy.xml
ed fitnessedotorg/ivy.xml << EOF
14s/version/$VERSION/g
w
EOF

echo "Generate static pages"
rm -rf fitnessedotorg/docs
mkdir fitnessedotorg/docs
java -jar fitnesse/build/libs/fitnesse-$VERSION-standalone.jar -d fitnessedotorg -c "?publish&destination=fitnessedotorg/docs" -p 8080

echo "Commit all and push"
(cd fitnessedotorg && git add ivy.xml docs releases/$VERSION && git commit -v -m "Release $VERSION via $0" || { git stash; die "Not committed (stashed), nothing to do."; }; ) \
	&& (cd fitnessedotorg && git push origin HEAD:master)

