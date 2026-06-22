# semantic-release Docker Image

Ubuntu-based Docker image for running
[semantic-release](https://semantic-release.gitbook.io/) in CI/CD pipelines.
It analyzes Conventional Commits, calculates the next version, creates release
notes and publishes releases without installing Node.js in the target project.

---

## Included Software

- Ubuntu 24.04
- Node.js 24.14.1
- semantic-release 25.0.5
- Git, OpenSSH client and trusted CA certificates
- `@semantic-release/changelog` 6.0.3
- `@semantic-release/commit-analyzer` 13.0.1
- `@semantic-release/exec` 7.1.0
- `@semantic-release/git` 10.0.1
- `@semantic-release/github` 12.0.8
- `@semantic-release/gitlab` 13.3.2
- `@semantic-release/npm` 13.1.5
- `@semantic-release/release-notes-generator` 14.1.1
- `conventional-changelog-conventionalcommits` 9.3.1

The image supports `linux/amd64` and `linux/arm64`.

---

## Build

```bash
docker build -t image-semantic-release .
docker run --rm image-semantic-release --version
```

---

## Usage

Run the container from the Git repository that is being released. The image's
working directory is `/workspace` and its entrypoint is `semantic-release`.

Dry run:

```bash
docker run --rm \
  -v "$(pwd):/workspace" \
  image-semantic-release \
  --dry-run --no-ci
```

GitHub release:

```bash
docker run --rm \
  -v "$(pwd):/workspace" \
  -e GH_TOKEN \
  image-semantic-release
```

GitLab release:

```bash
docker run --rm \
  -v "$(pwd):/workspace" \
  -e GL_TOKEN \
  image-semantic-release
```

Publish an npm package by additionally passing `NPM_TOKEN` and enabling
`@semantic-release/npm` in the release configuration.

---

## Docker Compose

The default Compose command performs a local dry run:

```bash
docker compose run --rm semantic-release
```

Export `GH_TOKEN`, `GL_TOKEN`, or `NPM_TOKEN` only when the selected plugins
require them. Do not store tokens in the repository.

---

## Automated Releases and GitHub Container Registry

The release process consists of two workflows:

1. A push to `main` runs semantic-release from the container configured in the
   `IMAGE_SEMANTIC_RELEASE` repository variable. It analyzes commits and pushes
   a new `vX.Y.Z` tag when a release is required.
2. A pushed `v*` tag starts the image build and publishes it to GHCR.

Semantic-release uses its default configuration. Commit types determine the
version change:

- `fix:` creates a patch release,
- `feat:` creates a minor release,
- a `BREAKING CHANGE:` footer creates a major release,
- commit types such as `docs:`, `test:` and `chore:` do not create a release.

The `package.json` is private because the default semantic-release plugins
include npm support. It provides the required package metadata without
publishing anything to npm.

The release workflow requires:

- repository variable `IMAGE_SEMANTIC_RELEASE` containing the complete image
  reference, including its tag,
- secret `SEMANTIC_RELEASE_TOKEN` containing a PAT with permission to push tags
  and create releases.

A separate token is required because tags pushed with the workflow's standard
`GITHUB_TOKEN` do not trigger another workflow. Release tags must not be created
manually.

The image is published to
`ghcr.io/eye-of-discipline/image-semantic-release` with these tags:

- full semantic version, for example `1.2.3`,
- minor version, for example `1.2`,
- major version, for example `1`,
- `latest`.

Pull and run a published image:

```bash
docker pull ghcr.io/eye-of-discipline/image-semantic-release:latest
docker run --rm \
  -v "$(pwd):/workspace" \
  -e GH_TOKEN \
  ghcr.io/eye-of-discipline/image-semantic-release:latest
```

## Security Notes

- Pass tokens as environment variables from the CI secret store.
- Mount only the repository that semantic-release needs to inspect and modify.
- Use an immutable version tag in production CI instead of `latest`.
- The Node.js archive is verified against the official SHA-256 checksum during
  the image build.

---

## License

See [LICENSE](LICENSE).

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Author Information

| ![Maciej Rachuna](https://gitlab.com/uploads/-/system/user/avatar/8161705/avatar.png?width=120px) |
|---------------------------------------------------------------------------------------------------|
| [Maciej Rachuna](https://gitlab.commrachuna)                                                      |