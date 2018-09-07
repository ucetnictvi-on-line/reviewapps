#!/usr/bin/env bash

shopt -s expand_aliases
source /usr/local/bin/reviewapps-helpers.sh

projectName=${1?"<project name> attribute is missing!"}
branchId=${2?"<branch id> attribute is missing!"}

ensureReviewappsRoot
check "$projectName"

appRoot=$(getAppRoot "$projectName" "$branchId")
composeName=$(getComposeProjectName "$projectName" "$branchId")

if [[ -d "$appRoot" ]]; then
    begin_dir "$appRoot"
        docker-compose --project-name "$composeName" -f docker-compose.yml -f docker-compose.reviewapps.yml down 2>/dev/null
    end_dir

    rm -Rf "$appRoot"
fi

exit 0
