#!/bin/bash

docker-compose down
docker volume rm ldap_motley_cue_sock ldap_openldap_data 
docker-compose up
