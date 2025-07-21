#!/bin/bash

wget -O - --quiet --timeout=5 --no-check-certificate --tries=1 https://kubernetes.arendse.nom.za/echo || echo "Failed to connect to kubernetes.arendse.nom.za"

kubectl get nodes --output=name | sed 's/node\///g' | while read node; do
    echo "Running echo test on $node"
    echo "Testing 10.200.171.21:5678"
    kubectl run echo-test \
        --image=alpine \
        --rm \
        -it \
        --quiet \
        --restart=Never \
        --overrides='{"spec":{"nodeName":"'$node'"}}' \
        -- sh -c "echo \$(hostname) && wget -O - --quiet --timeout=5 10.200.171.21:5678 || echo 'Failed to connect to 10.200.171.21:5678'"
    echo "Testing echo.echo:5678"
    kubectl run echo-test \
        --image=alpine \
        --rm \
        -it \
        --quiet \
        --restart=Never \
        --overrides='{"spec":{"nodeName":"'$node'"}}' \
        -- sh -c "echo \$(hostname) && wget -O - --quiet --timeout=5 echo.echo:5678 || echo 'Failed to connect to echo.echo:5678'"
    echo "Done"
done