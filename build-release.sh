
function isokay() {
    local ok
    echo "$* (y/N)"
    read ok
    test "x$ok" == "xy"
}

isokay "Is all cruft removed from the frontpage?" || exit

git status
isokay "Is okay?" || exit

. ~/fitnesse.release
ant release publish -Dupload.user=$uploaduser -Dupload.password=$uploadpassword -Dpgp.password=$pgppassword

isokay "Is the distro okay?" || exit

open http://oss.sonatype.org

isokay "Please release FitNesse on the maven repo?" || exit

RELEASEDIR="$SITE/FitNesseRoot/FrontPage/FitNesseDevelopment/FitNesseRelease$VERSION"
mkdir -p $RELEASEDIR
cat > $RELEASEDIR/properties.xml << EOF
<properties>
....
EOF

cat > $RELEASEDIR/content.txt << EOF
new release ....
EOF

# contributors
git log --pretty=format:"%an" --since="1/3/2010" | sort | uniq

# commit log
git log --pretty=format:"|%ad|%an|%s|" --date=short --since="12/1/2008"
