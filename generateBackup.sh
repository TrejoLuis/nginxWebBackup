#!/bin/bash

NAME=$1;
DIR=$2;
TMP=${DIR#/};
DIR_ROOT=${TMP%%/*};

#DIR_ROOT=${${DIR#/}%%/*};
if [[ ! $NAME || ! $DIR ]]; then
  echo "parameter/s missing";
  exit 1;
fi
if [[ ! $(git status) ]]; then
  echo "git repository not initialized, initialize it and set up a remote repo";
  exit 1;
fi
# validate if "automaticBackup" branch exists otherwise create it
if [[ ! $(git branch | grep -q 'automaticBackup') ]]; then
  # create branch
  git branch -m automaticBackup;
fi
# switch to branch if needed
if [[ $(git branch --show-current) != "automaticBackup" ]]; then
  git switch automaticBackup;
fi
# already in automaticBackup branch
docker run --rm --volumes-from $NAME -v $(pwd):/backup busybox tar cvf /backup/backup.tar $DIR;
tar -xf backup.tar;
rm -f backup.tar;

git add $DIR_ROOT;
git commit -m "chore: backup $(date "+%Y-%m-%d")";
git push -u origin automaticBackup;
