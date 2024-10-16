# Progress on Oct 15th

## Successful tasks:
* Test both roles, make them streamlined/fine tune, stable
* Put the common steps into a common.yml, revoke first by main.yml
* Keep different steps into the {{os}}.yml, revoke by main.yml
* Structure of molecule for elasticsearch 

### Need continue

* Continue working on molecule testing

Run `docker compose down -v && docker compose up -d`

Then `ansible-playbook -i inventory.yml playbook.yml` from `ansible/` folder. Append `-vvvv` in ansible playbook to enable verbose mode.
Run `molecule test` to test and `molecule --debug test` to run in verbose mode.
