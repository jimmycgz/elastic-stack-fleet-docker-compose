# Progress on Oct 11th

## Successful tasks:
* Fixed bug: the agent showed error on console saying error connection to fleet localhost:8220, though we explicitly configured the correct host in the `elastic-agent.yml` file. 
**Solution:** There was a misconfig at docker compose env for kibana, the value of XPACK_FLEET_AGENTS_FLEET_SERVER_HOSTS should be `["${FLEET_HOST}"]` instead of `["${FLEET_URL}"]`   the HOST is https://fleet:8220, and the URL is https://localhost:8220, where the fleet is in another container outside of the kibana container
**Highlight:** We don't need to rewrite the `elastic-agent.yml` because everything should be managed by the fleet, eg: the es host may not be https://es01:9200 for the agent, instead, should be localhost.

* **agent-ubuntu:** Fine tuned the bash script, can start updating the ansible role after testing on VMs.
* ** agent-debian:** Successfully enrolled from the tar extract folder, don't need install, just need to start the agent service at background model before enrollment.

### Need continue
* Continue test on VMs
* Fine tune the bash script if needed
* Fine tune the ansible role for ubuntu
* Build ansible role for debian
* Add condition check for debian: if system and systemctl exist, run `systemctl enable elastic-agent && systemctl start elastic-agent`

