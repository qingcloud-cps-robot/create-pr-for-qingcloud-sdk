#!/bin/sh -l

set -e  # if a command fails it stops the execution
set -u  # script fails if trying to access to an undefined variable

echo "[+] Action start"


USER_EMAIL="${1}"
USER_NAME="${2}"
DESTINATION_REPOSITORY_USERNAME="${3}"

TARGET_API_SPECS_BRANCH="${4}"
TARGET_BRANCH_SDK_MAIN="${5}"
TARGET_BRANCH_SDK_SYNC="${6}"

TARGET_REPOSITORY_NAME_API_SPECS="${7}"
TARGET_REPOSITORY_NAME_JAVA_SDK="${8}"
TARGET_REPOSITORY_NAME_GO_SDK="${9}"
TARGET_REPOSITORY_NAME_RUBY_SDK="${10}"

COMMIT_MESSAGE="${11}"

ORIGIN_COMMIT="https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"
echo $ORIGIN_COMMIT
# COMMIT_MESSAGE="${COMMIT_MESSAGE/ORIGIN_COMMIT/$ORIGIN_COMMIT}"
# COMMIT_MESSAGE="${COMMIT_MESSAGE/\$GITHUB_REF/$GITHUB_REF}"

CLONE_DIR=$(mktemp -d)

# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$USER_NAME"

echo "[+] Cloning $TARGET_REPOSITORY_NAME_API_SPECS"
mkdir $TARGET_REPOSITORY_NAME_API_SPECS
git clone --single-branch --branch "$TARGET_API_SPECS_BRANCH" "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$DESTINATION_REPOSITORY_USERNAME/$TARGET_REPOSITORY_NAME_API_SPECS.git" "$CLONE_DIR/$TARGET_REPOSITORY_NAME_API_SPECS"

ls -la "$CLONE_DIR/$TARGET_REPOSITORY_NAME_API_SPECS"


echo "[+] Cloning $TARGET_REPOSITORY_NAME_JAVA_SDK"
cd $CLONE_DIR
mkdir $TARGET_REPOSITORY_NAME_JAVA_SDK
git clone --single-branch --branch "$TARGET_BRANCH_SDK_SYNC" "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$DESTINATION_REPOSITORY_USERNAME/$TARGET_REPOSITORY_NAME_JAVA_SDK.git" "$CLONE_DIR/$TARGET_REPOSITORY_NAME_JAVA_SDK"

ls -la $CLONE_DIR/$TARGET_REPOSITORY_NAME_JAVA_SDK

echo "[+] Update $TARGET_REPOSITORY_NAME_JAVA_SDK by snips"
snips -f $CLONE_DIR/$TARGET_REPOSITORY_NAME_API_SPECS/2013-08-30/swagger/api_v2.0.json -t $CLONE_DIR/$TARGET_REPOSITORY_NAME_JAVA_SDK/tmpl -o $CLONE_DIR/$TARGET_REPOSITORY_NAME_JAVA_SDK/src/main/java/com/qingcloud/sdk/service/

echo "[+] Push $TARGET_REPOSITORY_NAME_JAVA_SDK to $TARGET_BRANCH_SDK_SYNC"
cd "$CLONE_DIR/$TARGET_REPOSITORY_NAME_JAVA_SDK"

echo "[+] Files that will be pushed"
ls -la

echo "[+] Adding git commit"
git add .

echo "[+] git status:"
git status

echo "[+] git diff-index:"
# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "[+] Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$DESTINATION_REPOSITORY_USERNAME/$TARGET_REPOSITORY_NAME_JAVA_SDK.git" --set-upstream "$TARGET_BRANCH_SDK_SYNC"

echo "[+] Cloning $TARGET_REPOSITORY_NAME_GO_SDK"
cd $CLONE_DIR
mkdir $TARGET_REPOSITORY_NAME_GO_SDK
git clone --single-branch --branch "$TARGET_BRANCH_SDK_SYNC" "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$DESTINATION_REPOSITORY_USERNAME/$TARGET_REPOSITORY_NAME_GO_SDK.git" "$CLONE_DIR/$TARGET_REPOSITORY_NAME_GO_SDK"

echo "[+] Update $TARGET_REPOSITORY_NAME_GO_SDK by snips"
snips -f ./$TARGET_REPOSITORY_NAME_API_SPECS/2013-08-30/swagger/api_v2.0.json -t ./$TARGET_REPOSITORY_NAME_GO_SDK/template -o ./qingcloud-sdk-go/service/

echo "[+] Push $TARGET_REPOSITORY_NAME_GO_SDK to $TARGET_BRANCH_SDK_SYNC"
cd "$CLONE_DIR/$TARGET_REPOSITORY_NAME_GO_SDK"

echo "[+] Format go files"
gofmt -w .

echo "[+] Files that will be pushed"
ls -la

echo "[+] Adding git commit"
git add .

echo "[+] git status:"
git status

echo "[+] git diff-index:"
# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "[+] Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$DESTINATION_REPOSITORY_USERNAME/$TARGET_REPOSITORY_NAME_GO_SDK.git" --set-upstream "$TARGET_BRANCH_SDK_SYNC"


echo "[+] Cloning $TARGET_REPOSITORY_NAME_RUBY_SDK"
cd $CLONE_DIR
mkdir $TARGET_REPOSITORY_NAME_RUBY_SDK
git clone --single-branch --branch "$TARGET_BRANCH_SDK_SYNC" "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$DESTINATION_REPOSITORY_USERNAME/$TARGET_REPOSITORY_NAME_RUBY_SDK.git" "$CLONE_DIR/$TARGET_REPOSITORY_NAME_RUBY_SDK"

echo "[+] Update $TARGET_REPOSITORY_NAME_RUBY_SDK by snips"
snips -f ./$TARGET_REPOSITORY_NAME_API_SPECS/2013-08-30/swagger/api_v2.0.json -t ./$TARGET_REPOSITORY_NAME_RUBY_SDK/template -o ./$TARGET_REPOSITORY_NAME_RUBY_SDK/lib/qingcloud/sdk/service/

echo "[+] Push $TARGET_REPOSITORY_NAME_RUBY_SDK to $TARGET_BRANCH_SDK_SYNC"
cd "$CLONE_DIR/$TARGET_REPOSITORY_NAME_RUBY_SDK"

echo "[+] Format ruby files"
rufo ./lib/qingcloud/sdk/service/*

echo "[+] Files that will be pushed"
ls -la

echo "[+] Adding git commit"
git add .

echo "[+] git status:"
git status

echo "[+] git diff-index:"
# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "[+] Pushing git commit"
# --set-upstream: sets de branch when pushing to a branch that does not exist
git push "https://$USER_NAME:$API_TOKEN_GITHUB@github.com/$DESTINATION_REPOSITORY_USERNAME/$TARGET_REPOSITORY_NAME_RUBY_SDK.git" --set-upstream "$TARGET_BRANCH_SDK_SYNC"
