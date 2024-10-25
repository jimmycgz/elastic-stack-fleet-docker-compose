# Contributing to Sectigo Ansible Collection - Critical Roles

Thank you for your interest in contributing to the Sectigo Ansible Collection - Critical Roles repository! This document outlines the guidelines and best practices for contributing to this project.

## Branch Protection and Default Branch

The default branch for this repository is `main`. The `main` branch is protected and requires pull request reviews and approvals before merging.

## Branching Nomenclature

When creating a new branch for your contributions, please follow one of these naming conventions:

- Use the JIRA ticket number associated with the work being done (e.g., `PAU-123`).
- If there is no associated JIRA ticket, use a meaningful and descriptive name for your branch (e.g., `add-new-role-feature`).

## Linting

To maintain code quality and consistency, all contributions must pass the following linting checks:

- Documentation: [Specify the linting tool and configuration for documentation files]
- Ansible:
  * Linting Tool: ansible-lint
  #### Note: ansible-lint is already available under devcontainers thus installation is not required.
  * Configuration:
     * Create a file named .ansible-lint in the root directory of the repository.
     * Add the following content to the .ansible-lint file:
```
exclude_paths:
  - .github/
  - molecule/
  - tests/
  
mock_roles:
  - geerlingguy.git
  - nginxinc.nginx

skip_list:
  - yaml[line-length]
  - yaml[truthy]

use_default_rules: true

verbosity: 1
```

   * Adjust the `exclude_paths` and `skip_list` according to your project's requirements.
   * The `use_default_rules` option ensures that the default set of linting rules provided by ansible-lint are used.
   * The `verbosity` option sets the level of verbosity for the linting output.

Check all supported values at [Ansible Docs](https://ansible.readthedocs.io/projects/lint/configuring/).

To run the linting checks for Ansible files, execute the following command in the root directory of the repository:
`ansible-lint roles/`
This command will lint all the Ansible roles located in the roles/ directory.
Please ensure that your code passes the ansible-lint checks before submitting a pull request. If there are any linting errors or warnings, address them accordingly.

You can customize the `.ansible-lint` configuration file based on your project's specific linting requirements. The `exclude_paths` option allows you to specify directories or files that should be excluded from linting. The `skip_list` option enables you to skip specific linting rules if needed.

## Testing

All contributions must include appropriate tests entails local testing and CI testing to verify the functionality and prevent regressions. When submitting a pull request, make sure that all existing tests pass and include any necessary new tests for your changes.

## Pull Request Guidelines

When creating a pull request, please adhere to the following guidelines:

1. Title:
   - Include the JIRA ticket number (if applicable) at the beginning of the pull request title (e.g., "feat(PAU-123) - Fix role issue").
   - Provide a clear and concise title that summarizes the purpose of the pull request.

2. Description:
   - Include a detailed description of the changes made in the pull request.
   - Explain the problem being solved or the roles being added.
   - Provide any necessary context or background information.
   - Reference any related issues or pull requests using the `#` symbol followed by the issue or pull request number.

3. Approval:
   - All pull requests require at least two approval from a code reviewer before merging.
   - CI testing success is required.
   - Reviewers should thoroughly review the changes and provide constructive feedback.
   - Address any comments or requested changes made by the reviewers before merging.

## Signing GPG Key
In case the merging is blocked due to unsigned commits, then signing all the commit would be mandatory. Follow [Retroactively Sign Git Commits Tutorial](https://webdevstudios.com/2020/05/26/retroactively-sign-git-commits/) to do it.

You want to make note of two things here. 
1. Find out how many commits you need to sign.
2. Use the name and email address attached to those commits. We’ll want to use the same name and email when setting up our GPG key.

MacOS instructions
If getting an error `error: gpg failed to sign the data` or `failed to write commit object` or `failed to write commit object`. Follow the instructions
```
brew install pinentry-mac
echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
git config --global gpg.program "$(which gpg)"
echo "no-tty" >> ~/.gnupg/gpg.conf
killall gpg-agent
```

## Reporting Issues

If you encounter any issues or have suggestions for improvements, please [open an issue](link-to-issue-tracker) in the repository. Provide a clear description of the problem or suggestion, along with any relevant details or steps to reproduce the issue.

## Contact

If you have any questions or need further assistance, please contact the project maintainers at [contact-email].

Thank you for your contributions and happy coding!

---
