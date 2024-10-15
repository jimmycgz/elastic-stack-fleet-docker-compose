# Progress on Oct 11th

## Successful tasks:
* Ansible for agent-ubuntu is working on container
* Both debian and ubuntu agents are working with docker compose 

### Need continue
* Ansible for debian on container

Run `docker compose up -d`
Then `ansible-playbook -i inventory.yml playbook.yml` from `ansible/` folder. Append `-vvv` in ansible playbook to enable verbose mode.