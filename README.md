# ci-aws

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/f4b87e390a774164ae1264ca2f59b7c3)](https://www.codacy.com/gh/codacy/ci-aws?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=codacy/ci-aws&amp;utm_campaign=Badge_Grade)
[![](https://images.microbadger.com/badges/version/codacy/ci-aws.svg)](https://microbadger.com/images/codacy/ci-aws "Get your own version badge on microbadger.com")

Docker image to be used in Continuous Integration environments such as CircleCI, with tools to interact with AWS

## Usage

#### CircleCI

Use this image directly on CircleCI for simple steps

```
version: 2
jobs:
  build:
    working_directory: /app
    docker:
      - image: codacy:ci-aws:1.0.0
    steps:
      - checkout
      - setup_credentials:
          name: setup aws credentials
          command: |
            mkdir -p ~/.aws && touch ~/.aws/credentials
            cat >> ~/.aws/credentials << EOF
            [default]
            aws_access_key_id=$ACCESS_KEY_ID
            aws_secret_access_key=$SECRET_ACCESS_KEY
            [ci_role]
            source_profile = default
            role_arn = arn:aws:iam::$PRODUCTION_AWS_ACCOUNT_ID:role/$PRODUCTION_ROLE
            EOF
      - run:
          name: get new version
          command: sceptre lunch-env dev
          environment:
            AWS_PROFILE: ci_role
```

# Build and Publish

The pipeline in `circleci` can deploy this for you when the code is pushed to the remote.

You can also run everything locally using the makefile
```
$ make help
---------------------------------------------------------------------------------------------------------
build and deploy help
---------------------------------------------------------------------------------------------------------
build                          build docker image
get-next-version-number        get next version number
git-tag                        tag the current commit with the next version and push
push-docker-image              push the docker image to the registry (DOCKER_USER and DOCKER_PASS mandatory)
push-latest-docker-image       push the docker image with the "latest" tag to the registry (DOCKER_USER and DOCKER_PASS mandatory)
```
