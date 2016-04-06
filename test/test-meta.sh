#!/usr/bin/env bash

. "test/testlib.sh"

metacontent="meta-test"

new_repo_for_meta() {
  suffix="$1"
  reponame="$(basename "$0" ".sh")-$suffix"
  setup_remote_repo "$reponame"
  clone_repo "$reponame" "$suffix"
}

begin_test "meta: pre-push to master"
(
  set -e

  new_repo_for_meta "pre-push-master"
  git lfs track "*.dat"

  content="meta-test: refs/heads/master"

  printf "$metacontent" > enable-meta-test.dat
  git add .
  git commit -m "commit"

  # fails without meta.dat added below
  set +e
  git push origin master
  if [ $? -eq 0 ]
  then
    exit 1
  fi
  set -e

  printf "$content" > meta.dat
  git add .
  git commit -m "commit"
  git push origin master
)
end_test

begin_test "meta: pre-push to branch"
(
  set -e

  new_repo_for_meta "pre-push-branch"
  git lfs track "*.dat"

  content="meta-test: refs/heads/branch"

  printf "$metacontent" > enable-meta-test.dat
  git add .
  git commit -m "commit"

  # fails without meta.dat added below
  set +e
  git push origin branch
  if [ $? -eq 0 ]
  then
    exit 1
  fi
  set -e

  printf "$content" > meta.dat
  git checkout -b branch
  git add .
  git commit -m "commit"
  git push origin branch
)
end_test

begin_test "meta: pre-push to remote branch"
(
  set -e

  new_repo_for_meta "pre-push-remotebranch"
  git lfs track "*.dat"

  content="meta-test: refs/heads/remotebranch"

  printf "$metacontent" > enable-meta-test.dat
  git add .
  git commit -m "commit"

  # fails without meta.dat added below
  set +e
  git push origin localbranch:remotebranch
  if [ $? -eq 0 ]
  then
    exit 1
  fi
  set -e

  printf "$content" > meta.dat
  git checkout -b localbranch
  git add .
  git commit -m "commit"
  git push origin localbranch:remotebranch
)
end_test

begin_test "meta: pre-push to tag"
(
  set -e

  new_repo_for_meta "pre-push-tag"
  git lfs track "*.dat"

  content="meta-test: refs/tags/v1.0"

  printf "$metacontent" > enable-meta-test.dat
  git add .
  git commit -m "commit"

  # fails without meta.dat added below
  set +e
  git push origin v1.0
  if [ $? -eq 0 ]
  then
    exit 1
  fi
  set -e

  printf "$content" > meta.dat
  git add .
  git commit -m "commit"
  git tag v1.0
  git push origin v1.0
)
end_test

begin_test "meta: push to master"
(
  set -e

  new_repo_for_meta "push-master"
  git lfs track "*.dat"

  content="meta-test: refs/heads/master"

  printf "$metacontent" > enable-meta-test.dat
  git add .
  git commit -m "commit"

  # fails without meta.dat added below
  set +e
  git lfs push origin master
  if [ $? -eq 0 ]
  then
    exit 1
  fi
  set -e

  printf "$content" > meta.dat
  git add .
  git commit -m "commit"
  git lfs push origin master
)
end_test

begin_test "meta: push to branch"
(
  set -e

  new_repo_for_meta "push-branch"
  git lfs track "*.dat"

  content="meta-test: refs/heads/branch"

  printf "$metacontent" > enable-meta-test.dat
  git add .
  git commit -m "commit"

  # fails without meta.dat added below
  set +e
  git lfs push origin branch
  if [ $? -eq 0 ]
  then
    exit 1
  fi
  set -e

  printf "$content" > meta.dat
  git checkout -b branch
  git add .
  git commit -m "commit"
  git lfs push origin branch
)
end_test

begin_test "meta: fetch from master"
(
  set -e
  new_repo_for_meta "fetch-master"

  git lfs track "*.dat"
  git add .
  git commit -m "track"
  git push origin master

  content1="meta-test: refs/heads/master"
  content2="meta-test: refs/heads/branch"

  printf "$metacontent" > enable-meta-test.dat
  git add .
  git commit -m "enable meta test"

  git checkout -b branch

  printf "$content1" > meta-master.dat
  printf "$content2" > meta-branch.dat
  git add .
  git commit -m "add meta checks for master and branch"
  git push origin branch

  git checkout master
  rm -rf .git/lfs/objects
  git lfs ls-files

  # fails since master doesn't have meta-master.dat yet
  set +e
  git lfs fetch origin master
  if [ $? -eq 0 ]
  then
    exit 1
  fi
  set -e

  git merge branch
  git push origin master
  rm -rf .git/lfs/objects
  git lfs ls-files
  git lfs fetch origin master
)
end_test

begin_test "meta: fetch from branch"
(
  set -e
  new_repo_for_meta "fetch-branch"

  git lfs track "*.dat"
  git checkout -b branch
  git add .
  git commit -m "track"

  content="meta-test: refs/heads/branch"

  printf "$metacontent" > enable-meta-test.dat
  printf "$content" > meta-branch.dat
  git add .
  git commit -m "add meta files"
  git push origin branch

  rm -rf .git/lfs/objects
  git lfs ls-files
  git lfs fetch origin branch
)
end_test
