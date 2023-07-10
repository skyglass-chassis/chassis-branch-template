#! /bin/bash -e

export ROOT=$(pwd)

export THE_DIR="${ROOT}/build/published-service-template"

if [ ! -d "$THE_DIR" ] ; then
  if ! git branch -r | grep origin/published-service-template ; then
    git checkout --orphan published-service-template
    git rm -r --cached .
    git add .gitignore
    git commit -am "Initial commit"
    git push -u origin published-service-template
    git checkout -
  fi
  git worktree add -B published-service-template $THE_DIR origin/published-service-template
fi

cd $THE_DIR

git reset --hard origin/published-service-template
git pull

rm -fr .gitignore .github [_a-zA-Z0-9]*

cp -r $ROOT/service-template/* .

rm -fr service-chassis-*

sed -i.bak -e '/service-chassis/d' -e "s?^.*MAVEN_REPO_URL.*\$?          url = uri(\"${1?}\")?" settings.gradle.kts
rm *.bak

cp -r $ROOT/.gitignore $ROOT/dot.testcontainers.properties .

mkdir -p .github/workflows

cp $ROOT/_github_build_workflows/* ./.github/workflows

#./gradlew compileAll

git add .

git diff-index --quiet HEAD || git commit -am "Updated"

git push
