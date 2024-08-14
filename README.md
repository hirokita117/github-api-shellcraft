# GitHub API ShellCraft

This repository is a collection of shell scripts for the github api and gh command.

## Setup

1. Clone this repository:
   ```sh
   git clone git@github.com:hirokita117/github-api-shellcraft.git
   cd github-api-shellcraft
   ```

2. Each script loads environment variables from `env.sh`. Make sure to configure `env.sh` correctly before running any scripts. Therefore, please copy `env.sample.sh` beforehand and create `env.sh`.
   ```sh
   cp env.sample.sh env.sh
   ```

3. Edit the `env.sh` file and set your GitHub account information:
   ```sh
   vi env.sh
   ```
   Change GITHUB_TOKEN, GITHUB_OWNER, and GITHUB_REPO to appropriate values.

4. If you haven't installed the GitHub CLI, follow the [official guide](https://github.com/cli/cli#installation) to install it.

5. Authenticate with GitHub CLI:
   ```sh
   gh auth login
   ```

## List of Scripts
- [env.sample.sh (env.sh)](env.sample.sh)
  - Sets environment variables
- [scripts/gh_command_sample.sh](scripts/gh_command_sample.sh)
  - Fetches the list of issues for a repository
- [scripts/pull_request_review_comment.sh](scripts/pull_request_review_comment.sh)
  - Fetches pull request review comment for a repository
- [scripts/merged_pull_request.sh](scripts/merged_pull_request.sh)
  - Get the number of merged pull requests, given an arbitrary time period

## Usage
Simply run the shell script.
```sh
./scripts/gh_command_sample.sh
```

## Notes

- `GITHUB_TOKEN` is sensitive information. Be careful not to commit the `env.sh` file to a public repository.
