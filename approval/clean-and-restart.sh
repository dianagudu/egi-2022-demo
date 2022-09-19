#!/bin/bash

docker-compose down
docker volume rm approval_motley_cue_sock 
docker-compose up
