#!/bin/bash
source ~/.bashrc
GITSHA=$(git rev-parse --short HEAD)

case "$1" in 
    build)
        # login to docker hub
        ansible-playbook login.yml --vault-password-file ~/.vault_pass.txt
        # build image from Dockerfile
        docker build -t qdd:$GITSHA
        # tag the image for DockerHub
        docker tag qdd:$GITSHA shervain/qdd:$GITSHA
        # push the image to DockerHub
        docker push shervain/qdd:$GITSHA
    ;;
    deploy)
        # set deployment environment
        if [ $2 = 'staging' || $2 = 'prod' ]
        then
            export DEPLOY_ENV=$2
        else
            echo "Invalid deployment environment."
            exit 1
        fi
        # set docker image tag
        export TAG=$GITSHA
        ansible-playbook ../infrastructure/infrastructure.yml
    ;;
    *)
        echo "Invalid build step"
        exit 1
    ;;
esac
