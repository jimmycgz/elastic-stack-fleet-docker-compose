# Progress on Oct 15th

## Successful tasks:
* Finetuned doc for Ansible Role for agent-ubuntu
* Built and tested Ansible Role for agent-debian is working on container
* Both roles debian and ubuntu agents are working with docker compose 

### Need continue
* Test both roles, make them streamlined/fine tune, stable
* Put the common steps into a common.yml, revoke first by main.yml
* Keep different steps into the {{os}}.yml, revoke by main.yml
* Start working on molecule, focus on containers

Run `docker compose down -v && docker compose up -d`
Then `ansible-playbook -i inventory.yml playbook.yml` from `ansible/` folder. Append `-vvvv` in ansible playbook to enable verbose mode.


## The full prompt for how did I generate the new role for debian, just worked after only 5% fine tune.

given this working bash script for ubuntu:
...bashscript
...

I made this role work:
... ansible role for ubuntu
...

below bash script also works for debian:
...bashscript
...

then can you create a new role for debian, just the main.yml

