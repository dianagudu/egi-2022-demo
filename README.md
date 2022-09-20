# motley-cue: EGI Demo 2022

This repository provides different Docker-based test environments for SSH servers capable of doing OIDC authentication. The servers have [motley-cue](https://motley-cue.readthedocs.io) and [pam-ssh-oidc](https://git.man.poznan.pl/stash/scm/pracelab/pam.git) installed. For more information, read [here](https://github.com/EOSC-synergy/ssh-oidc).

The following use cases are supported:

- approval workflow with local unix accounts
- LDAP backend


## Approval workflow

Go to [approval/](approval) folder.

You'll first need to configure an email notifier. The config file is configured to use Google, but you'll need to change a few things in `config_files/feudal_adapter.conf`, in the `[notifier.email]` section (look for the string `CHANGEME`):

- your google email address to send the emails from
- your google account's API password that you'll need to set up with google
- the email address of the admin that will receive the requests and approve/reject them

You can modify the ports for SSH & motley-cue in `.env`.

Then spin up the containers and try to ssh in with your `egi` identity, e.g. here configured as `egi-keycloak` in the oidc-agent.

```bash
cd approval
docker-compose up
mccli --mc-endpoint localhost:8001 --oidc egi-keycloak ssh -p 2201 localhost
```

You should have received a notification for the request to deploy a local user. To accept it, execute the following in the appropriate container (add your own `sub`):

```bash
docker-compose exec -it ssh_oidc bash

echo '{
    "state_target": "accepted",
    "user": {
        "userinfo": {
            "sub": ...,
            "iss": "https://aai.egi.eu/auth/realms/egi"
        }
    }
}' | feudal-adapter
```

Then log in again and it should open an SSH session:
```bash
mccli --mc-endpoint localhost:8001 --oidc egi-keycloak ssh -p 2201 localhost
```

### LDAP backend

Go to [ldap/](ldap) folder.

You can modify the ports for SSH & motley-cue in `.env`. Below we user the ports as already configured.

```bash
cd ldap
docker-compose up
mccli --mc-endpoint localhost:8002 --oidc egi-keycloak ssh -p 2202 localhost
```