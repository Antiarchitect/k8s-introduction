#!/usr/bin/env bash

set -eo pipefail

cd "$(dirname "${0}")" || exit 1

context="default"
app="myapp"

if ! kubectl config use-context "${context}"; then
    echo "Cannot change kubectl context to ${context}. Please check the context exists. Exiting..."
    exit 1
fi

echo "Linting..."
if ! helm lint --debug .; then
    echo "Helm linter has failed. Please fix your chart before proceed. Exiting..."
    exit 1
fi
echo "Linting OK"
echo

echo "Deployment..."
if ! helm upgrade "${app}" . \
     --atomic \
     --cleanup-on-fail \
     --create-namespace \
     --debug \
     --install \
     --namespace="${app}" \
     --reset-values \
     --timeout=15m;
then
    echo "Deployment of \"${app}\" has failed. Exiting..."
    exit 1
fi
echo "Deployment OK"
