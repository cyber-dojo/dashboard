![Github Action (main)](https://github.com/cyber-dojo/dashboard/actions/workflows/main.yml/badge.svg?branch=main)


- A [docker-containerized](https://registry.hub.docker.com/r/cyberdojo/dashboard) micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- The HTTP UI for a group-exercise dashboard.
- Demonstrates a [Kosli](https://www.kosli.com/) instrumented [GitHub CI workflow](https://app.kosli.com/cyber-dojo/flows/dashboard-ci/trails/) 
  deploying, with Continuous Compliance, to [staging](https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/) and [production](https://app.kosli.com/cyber-dojo/environments/aws-prod/snapshots/) AWS environments.
- Uses patterns from https://www.kosli.com/blog/using-kosli-attest-in-github-action-workflows-some-tips/

# Development

```bash
# To build the image
$ make image_server

# To run all tests
$ make test_server

# To run only specific tests
$ ./bin/run_tests.sh {-h|--help}
$ ./bin/run_tests.sh server 449AC6

# To check coverage metrics
$ make coverage_server

# To run snyk-container-scan
$ make snyk_container_scan

# To run rubocop-lint
$ make rubocop_lint

# To run demo
$ make demo
```

- - - -
* [GET alive](docs/api.md#get-alive)  
* [GET ready](docs/api.md#get-ready)
* [GET sha](docs/api.md#get-sha)
* [GET base_image](docs/api.md#get-base-image)
* ...

- - - -
![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
