
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := cyberdojo/differ:${SHORT_SHA}

.PHONY: all test lint snyk demo image

all: test lint snyk demo

test:
	${PWD}/build_test.sh

lint:
	docker run --rm --volume "${PWD}:/app" cyberdojo/rubocop --raise-cop-error

snyk:
	snyk container test ${IMAGE_NAME}
        --file=Dockerfile
        --json-file-output=snyk.container.scan.json
        --policy-path=.snyk

demo:
	${PWD}/demo.sh
