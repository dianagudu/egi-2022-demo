#!/bin/bash

docker-compose down
docker volume rm approval_motley_cue_sock
ssh-keygen -R '[localhost]:2201'
