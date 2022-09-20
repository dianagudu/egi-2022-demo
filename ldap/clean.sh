#!/bin/bash

docker-compose down
docker volume rm ldap_motley_cue_sock ldap_openldap_data
ssh-keygen -R '[localhost]:2202'
