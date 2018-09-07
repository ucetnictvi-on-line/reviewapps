#!/usr/bin/env bash

source /usr/local/etc/reviewapps.conf

function errorMessage() {
    echo -e >&2 "$1"
}

function ensureReviewappsRoot() {
    mkdir -p "$ROOT"
}

function getProjectDir() {
    local projectName="$1"

    echo "${ROOT}/${projectName}"
}

function getAppBuilder() {
    local projectName="$1"
    local projectDir
    projectDir=$(getProjectDir "$projectName")

    echo "${projectDir}/bin/build.sh"
}

function getAppRoot() {
    local projectName="$1"
    local branchId="$2"

    echo "${ROOT}/${projectName}/apps/${branchId}"
}

function checkDependencies() {
    if ! type docker-compose >/dev/null; then
        errorMessage "Missing dependency: docker-compose"
        exit 2
    fi
}

function getComposeProjectName() {
    local projectName="$1"
    local branchId="$2"

    echo "${projectName}-${branchId}"
}

function checkResources() {
    local freeMemoryMB
    freeMemoryMB=$(free -m | sed -n '2p' | awk '{ print $7 }')

    if (( freeMemoryMB < LIMIT_MEMORY )); then
        errorMessage "Not enough memory (${freeMemoryMB}MB) to launch new app! Try to stop some other."
        exit 3
    fi
}

function checkProject() {
    local projectName="$1"
    local projectBuilder
    projectBuilder=$(getProjectDir "$projectName")

    if [[ ! -x "$projectBuilder" ]]; then
        errorMessage "Project ${projectName} is not initialized!"
        exit 4
    fi
}

function check() {
    local projectName="$1"

    echo "App: ${DOMAIN?"DOMAIN env variable is missing!"}"

    checkDependencies
    checkProject "$projectName"
    checkResources
}

function testAppIsUp() {
    local appUrl="$1"

    if [ -z "$REVIEWAPPS_AUTH" ]; then
        curl "${appUrl}" -o /dev/null -sSf -w 'App response code: %{http_code}' 2>/dev/null
        return $?
    else
        curl "${appUrl}" -u "${REVIEWAPPS_AUTH}" -o /dev/null -sSf -w 'App response code: %{http_code}' 2>/dev/null
        return $?
    fi
}

function waitUntilAppIsUp() {
    local appUrl="$1"
    local stopTime=$(($(date +"%s") + "$MAX_APP_TEST_TIME"))

    echo "Waiting for ${appUrl}"

    sleep 10

    until testAppIsUp "${appUrl}"; do
        local currentTime="$(date +"%s")"

        echo

        if (( stopTime < currentTime )); then
            errorMessage "App is not responding (in ${MAX_APP_TEST_TIME}s)!"
            exit 5
        fi

        sleep 10
    done
}

export -f errorMessage
export -f ensureReviewappsRoot
export -f getProjectDir
export -f getAppBuilder
export -f getAppRoot
export -f checkDependencies
export -f getComposeProjectName
export -f checkResources
export -f checkProject
export -f check
export -f waitUntilAppIsUp

alias begin_dir='pushd >/dev/null'
alias end_dir='popd >/dev/null'
