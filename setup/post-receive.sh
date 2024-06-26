#!/usr/bin/env bash
echo "##### post-receive hook #####"
read oldrev newrev refname
echo "Push triggered update to revision $newrev ($refname)"

RUN_FOR_REF="refs/heads/main"
if [[ "$refname" ==  "$RUN_FOR_REF" ]]; then
    GIT="env -i git"
    CMD_CD="cd $(readlink -nf "$PWD/..")"
    CMD_FETCH="$GIT fetch"
    CMD_INSTALL="npm ci"
    CMD_RESTART="pm2 restart pm2.json"

    echo "$ $CMD_CD"
    eval ${CMD_CD}
    echo "$ $CMD_FETCH"
    eval ${CMD_FETCH}

    if $GIT diff --name-only $oldrev $newrev | grep "^package-lock.json"; then
        echo "$ $CMD_INSTALL"
        eval $CMD_INSTALL
    else
        echo "# Skipping npm install, lockfile not modified"
    fi

    echo "$ $CMD_RESTART"
    eval $CMD_RESTART
else
    echo "Ref does not match $RUN_FOR_REF, exiting."
fi

echo "##### end post-receive hook #####"
