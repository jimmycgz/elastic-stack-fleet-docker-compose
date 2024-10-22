# Molecule Test Tips

## Known Issues

* Sometimes `molecule test -s es-agent` throws error, you can try step by step as below:

```
molecule create     # Only create the instance
molecule converge   # Only run ansible playbook
molecule login      # SSH into the instance
```
I got error on this task when running the full test, and worked on the separate steps:
```
TASK [../../roles/es-agent : Fail if Kibana is not reachable] 
```

## More debug tips

To debug Molecule tests, there are several approaches you can use. Here are the key debugging methods:

1. Increase verbosity with `-v` flags:
```bash
# Increasing levels of verbosity
molecule -v test
molecule -vv test
molecule -vvv test
```

2. Use `molecule list` to check instance state:
```bash
molecule list
```

3. Debug without destroying the instance:
```bash
molecule create     # Only create the instance
molecule converge   # Only run ansible playbook
molecule login      # SSH into the instance
```

4. Log into the running instance for inspection:
```bash
molecule login
# or specify instance if multiple exist
molecule login --host instance-name
```

5. Use `--debug` flag to keep temporary files:
```bash
molecule --debug test
```

6. Show steps without executing (dry-run):
```bash
molecule check
```

7. Add debugging tasks to your playbook:
```yaml
- name: Debug variables
  debug:
    var: some_variable
    verbosity: 2

- name: Debug message
  debug:
    msg: "Current state: {{ state_variable }}"
```

8. Check logs in `.molecule` directory:
```bash
ls -la .molecule/
cat .molecule/*/ansible.log
```

9. Use `molecule.yml` configuration for debugging:
```yaml
provisioner:
  name: ansible
  log: true
  options:
    vv: true
```

Would you like me to elaborate on any of these methods or show you how to debug a specific issue?