# Contributing to Godwoken-Kicker

We use the [Trunk-Based Development Flow](https://trunkbaseddevelopment.com/branch-for-release/). We maintain only one long-lived branch, the "main" branch. 

## Pull Request

- Most of the time, you should submit PRs to the "main" branch.
- When submitting PR and it should be noted in the release note, please write down the release note in the PR description and mark the PR with "release-note" label
- When submiting PR and it brings breaking-changs, please please write down the release note in the PR description and mark the PR with "release-note" and "breaking-change" label

## Release Process

- At the scheduled time, checkouts a "rc-" branch from the current "main" branch
- As for non-emergence commits and patches, submit PRs to the "main" branch, then cherry-pick commits from "main" to "rc-"
- As for emergence hotfix, although Godwoken-Kicker should have no emergence hotfixes, make PRs to "rc-hotfix" branch, then cherry-pick to "main" branch.
- Since Godwoken-Kicker is not a production project, we don't have to maintain a CHANGELOG.md.

## Update a component

Godwoken-Kicker maintains component services via [docker-compose.yml](../docker/docker-compose.yml). To update a component, point the `image:` keyword to the updated Docker image. Here is an example https://github.com/RetricSu/godwoken-kicker/pull/266
