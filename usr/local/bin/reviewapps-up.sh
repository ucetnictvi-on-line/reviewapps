#!/usr/bin/env bash

shopt -s expand_aliases
source /usr/local/bin/reviewapps-helpers.sh

projectName=${1?"<project name> attribute is missing!"}
branchId=${2?"<branch id> attribute is missing!"}
sourceDir=${3?"<source dir> attribute is missing!"}

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

mkdir -p "$appRoot"

[[ -d "$sourceDir" ]] || { errorMessage "Source dir '${sourceDir}' is not present!"; exit 5; }

cp -R "${sourceDir%/}/." "${appRoot}/"

begin_dir "$appRoot"
    $(getAppBuilder "$projectName") "$projectName" "$branchId"
    docker-compose --project-name "$composeName" -f docker-compose.yml -f docker-compose.reviewapps.yml up --build -d
end_dir

waitUntilAppIsUp "https://${DOMAIN}"

exit 0
