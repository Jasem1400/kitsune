#!/bin/bash

# Run this from the project root--not from this directory!

git clone https://github.com/mozilla-l10n/sumo-l10n.git locale
cd locale

function lintpo() {
    commit=$1
    pofile=$2

    ../scripts/dennis_shim.py lint --errorsonly "${pofile}"
    if [ $? -eq 0 ]
    then
        compilemo $pofile
        return 0
    fi

    echo "lint returned an error, trying again with a previous version"
    # find the next most recent commit the file was modified in
    commit=$(git log -n1 --format=%H ${commit}~1 -- $pofile)
    # checkout the file from that commit
    git checkout $commit $pofile
    # try linting again
    lintpo $commit $pofile
}

function compilemo() {
    dir=`dirname $1`
    stem=`basename $1 .po`

    echo "Compiling $1..."
    msgfmt -o "${dir}/${stem}.mo" "$1"
}

for pofile in `find ./ -name "*.po"`
do
    lintpo HEAD $pofile
done
