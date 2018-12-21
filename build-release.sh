#!/bin/bash

VERSION=`date +%Y%m%d`
DATE=`date +%Y/%m/%d`
RELEASEDIR="FitNesseRoot/FrontPage/FitNesseDevelopment/FitNesseRelease$VERSION"
DOWNLOADPAGE="FitNesseRoot/FitNesseDownload/content.txt" 
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

git submodule update --recursive --remote || die "Can not update submodules"

OLDVERSION=`grep '^!release ' fitnessedotorg/$DOWNLOADPAGE | head -1 | cut -d ' ' -f 2`

echo "Releasing $VERSION. Old version: $OLDVERSION"

isokay "Is all cruft removed from the frontpage?" || exit
isokay "Is the ReleaseNotes page up to date?" || exit

(cd fitnesse && git status) && isokay "Is okay?" || exit

(cd fitnesse && gradle clean release) || exit

isokay "Is the distro okay?" || exit

open https://bintray.com/fitnesse/release/fitnesse

isokay "Please release FitNesse on the maven repo?" || exit

echo Building contributors
(cd fitnesse && git log --pretty=format:" * %an" "$OLDVERSION..HEAD" | sort | uniq) > contributors.tmp
$EDITOR contributors.tmp

echo Building commit log
(cd fitnesse && git log --pretty=format:"|%ad|%an|%s|" --date=short "$OLDVERSION..HEAD") > commitlog.tmp
$EDITOR commitlog.tmp

echo Building release notes
cat fitnesse/FitNesseRoot/FitNesse/ReleaseNotes/content.txt > releasenotes.tmp
$EDITOR releasenotes.tmp


mkdir -p fitnessedotorg/$RELEASEDIR
cat > fitnessedotorg/$RELEASEDIR/properties.xml << EOF
<?xml version="1.0"?>
<properties>
	<Edit>true</Edit>
	<Files>true</Files>
	<LastModifyingUser>`whoami`</LastModifyingUser>
	<Properties>true</Properties>
	<RecentChanges>true</RecentChanges>
	<Refactor>true</Refactor>
	<Search>true</Search>
	<Versions>true</Versions>
	<WhereUsed>true</WhereUsed>
</properties>
EOF

cat > fitnessedotorg/$RELEASEDIR/content.txt << EOF
!release $VERSION

!3 FitNesse Release Notes $DATE
!note Uncle Bob Consulting LLC.

!note !style_red(Requires Java 1.7)

!4 Major Changes since [[$OLDVERSION][FitNesseRelease$OLDVERSION]]:

`cat releasenotes.tmp`

!4 Github ids of Contributors to this release:

`cat contributors.tmp`

!meta Thanks to all of you!

!3 Git History

!`cat commitlog.tmp`
EOF

echo "Moving current release to old releases, define a new release"
ed fitnessedotorg/$DOWNLOADPAGE << EOF
2t/^!2 Old Releases/
2s/$OLDVERSION/$VERSION/g
w
EOF

echo "Copying fitnesse-standalone.jar to fitnesse.org"
mkdir fitnessedotorg/releases/$VERSION
cp fitnesse/build/libs/fitnesse-$VERSION-standalone.jar fitnessedotorg/releases/$VERSION/fitnesse-standalone.jar || die "Can not copy fitnesse-standalone.jar"

echo "Setup fitnesse.org to use $VERSION"
ed fitnessedotorg/ivy.xml << EOF
14s/$OLDVERSION/$VERSION/g
w
EOF

echo "Commit all and push"
(cd fitnessedotorg && git add $DOWNLOADPAGE $RELEASEDIR releases/$VERSION && git commit -v -m "Release $VERSION via $0" || { git stash; die "Not committed (stashed), nothing to do."; }; ) \
	&& (cd fitnessedotorg && git push)

