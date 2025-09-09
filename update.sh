#!/bin/bash -e

## Get latest version of the module
# https://pkg.go.dev/github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/dnspod?tab=versions
LIB_VERSION=$(go list -u -m -retracted -json github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/dnspod@latest | jq -r '.Version')
# LIB_VERSION=v1.0.1208

SRC_ORG=TencentCloud
DEST_ORG='go-acme'

SRC_REPO_NAME='tencentcloud-sdk-go'
DEST_REPO_NAME=tencentclouddnspod

SRC_REMOTE="git@github.com:${SRC_ORG}/${SRC_REPO_NAME}.git"
DEST_REMOTE="git@github.com:${DEST_ORG}/${DEST_REPO_NAME}.git"

DEST_BRANCH=modifiedclient

SRC_DIR=$(mktemp -d)
DEST_DIR=$(mktemp -d)

#############

## Fake fork remote
# DEST_REMOTE=$(mktemp -d)
#
# git init -q --bare ${DEST_REMOTE}
#
# DEST_TEMP=$(mktemp -d)
# git clone -q ${DEST_REMOTE} ${DEST_TEMP}
#
# cd ${DEST_TEMP}
# git switch -q -c ${DEST_BRANCH}
# git commit -q -m "Initial empty commit" --allow-empty
# git push -q -u origin ${DEST_BRANCH}
# cd ..
#
# rm -rf ${DEST_TEMP}

## Prepare the fork
# git clone -q --single-branch git@github.com:${DEST_ORG}/${DEST_REPO_NAME}.git /tmp/${DEST_REPO_NAME}
# cd /tmp/${DEST_REPO_NAME}
# git checkout --orphan ${DEST_BRANCH}
# git rm -rf .
# git commit -m "chore: initial empty commit." --allow-empty
# git push origin ${DEST_BRANCH}
# exit 0

#############

## Clone original repository

rm -rf ${SRC_DIR}

git clone -c advice.detachedHead=false -q --branch ${LIB_VERSION} --single-branch --depth 1 "${SRC_REMOTE}" ${SRC_DIR}

rm -rf ${SRC_DIR}/.git

## Clone destination repository

rm -rf ${DEST_DIR}

git clone -q --branch ${DEST_BRANCH} --single-branch ${DEST_REMOTE} ${DEST_DIR}

cd ${DEST_DIR}

## Remove all files
git rm -f -r --ignore-unmatch '*'

## Copy the code from the sources
cp -r ${SRC_DIR}/tencentcloud/dnspod/. .

## Change module name
go mod edit -module github.com/${DEST_ORG}/${DEST_REPO_NAME}

## Convert the code
sed -E '
# --- Transform method definitions ---

# For methods ending with WithContext
s/^func \(c \*Client\) ([A-Za-z0-9_]+WithContext)\(ctx context\.Context, *(.*)\)/func \1(ctx context.Context, c *Client, \2)/

# For methods NOT ending with WithContext
s/^func \(c \*Client\) ([A-Za-z0-9_]+)\((.*)\)/func \1(c *Client, \2)/

# --- Transform method calls like c.MethodXWithContext(...) ---

s/\bc\.([A-Za-z0-9_]+WithContext)\(([^ ]*)\)/\1(\2), c/g

' v20210323/client.go > v20210323/modifiedclient.go

rm v20210323/client.go

## Check compilation
go mod tidy
go build ./v20210323/
rm go.sum

## Commit and Push

git add .
git commit -q -m "feat: update to ${LIB_VERSION}"

git push -q origin ${DEST_BRANCH}
git tag ${LIB_VERSION}
git push -q origin ${LIB_VERSION}

cd ..

rm -rf ${SRC_DIR}
rm -rf ${DEST_DIR}

##########################

# echo ${DEST_DIR}
#
# rm -rf ${DEST_REMOTE}
#
# cd /home/ldez/sources/go-acme/lego
#
# go mod edit -dropreplace github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/dnspod
# go mod edit -replace github.com/tencentcloud/tencentcloud-sdk-go/tencentcloud/dnspod=${DEST_DIR}
# go mod tidy
