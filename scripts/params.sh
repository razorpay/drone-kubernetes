#!/bin/bash
set -euo pipefail
# set -o nounset

# globals
USER=""
NAMESPACE=""
CLUSTER=""
SERVER_URL=""

# set globals
setUser(){
    USER=${PLUGIN_USER:-default}
}

setNamespace(){
    NAMESPACE=${PLUGIN_NAMESPACE:-default}
}

setCluster(){
    CLUSTER_LOCAL=$1
    if [ ! -z "${CLUSTER_LOCAL}" ]; then
        # convert cluster name to ucase and assign
        CLUSTER=${CLUSTER_LOCAL^^}
        CLUSTER=${CLUSTER//-}
    else
        echo "[ERROR] Required pipeline parameter: cluster not provided"
        exit 1
    fi
}

setServerUrl(){
    # create dynamic cert var names
    local SERVER_URL_VAR=SERVER_URL_${CLUSTER}
    SERVER_URL=${!SERVER_URL_VAR}
    if [[ -z "${SERVER_URL}" ]]; then
        echo "[ERROR] Required drone secret: '${SERVER_URL_VAR}' not added!"
        exit 1
    fi
}

setKind(){
    if [ ! -z "${PLUGIN_KIND:-}" ]; then
        # convert cluster name to ucase and assign
        KUBE_KIND=${PLUGIN_KIND^^}
        if ! [[ "${KUBE_KIND}" =~ ^(DEPLOYMENT|DAEMONSET)$ ]]; then
            echo "[ERROR] Only deployment and daemonset kinds are supported now."
            echo 1
        fi
    else
        KUBE_KIND="DEPLOYMENT"
        echo "[WARN] Required pipeline parameter: kind not provided, defaulting to deployment."
    fi
}

setGlobals(){
    setCluster $1
    setUser
    setNamespace
    setServerUrl
    setKind
}
