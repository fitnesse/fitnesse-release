#!/usr/bin/bash

VERSION=`date +%Y%m%d`
DATE=`date +%Y/%m/%d`
RELEASEDIR="FitNesseRoot/FrontPage/FitNesseDevelopment/FitNesseRelease$VERSION"
DOWNLOADPAGE="FitNesseRoot/FitNesseDownload/content.txt" 



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

test -x build-release.conf || die "No build-release.conf found."
. build-release.conf

#git submodule update || die "Can not update submodules"

OLDVERSION=`grep '^!release ' content.txt | head -1 | cut -d ' ' -f 2`

echo "Releasing $VERSION. Old version: $OLDVERSION"

isokay "Is all cruft removed from the frontpage?" || exit

(cd fitnesse && git status) && isokay "Is okay?" || exit

# TODO: display releaseNotes page. Is this okay?

(cd fitnesse && ant release publish -Dupload.user=$uploaduser -Dupload.password=$uploadpassword -Dpgp.password=$pgppassword)

isokay "Is the distro okay?" || exit

open http://oss.sonatype.org

isokay "Please release FitNesse on the maven repo?" || exit

echo Building contributors
(cd fitnesse && git log --pretty=format:" * %an" --since="$lastreleasedate" | sort | uniq) > contributors.tmp
vi contributors.tmp

echo Building commit log
`(cd fitnesse && git log --pretty=format:"|%ad|%an|%s|" --date=short --since="$lastreleasedate")` > commitlog.tmp
vi commitlog.tmp

echo Building release notes
echo " * First major change" > releasenotes.tmp
vi releasenotes.tmp


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

!note !style_red(Requires Java 1.6)

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
cp fitnesse/dist/fitnesse-standalone.jar fitnessedotorg/releases/$VERSION

echo "Commit all"
(cd fitnessedotorg && git add $DOWNLOADPAGE $RELEASEDIR releases/$VERSION && git commit -v)

(cd fitnesse && git tag $VERSION)