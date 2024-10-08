
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := cyberdojo/dashboard:${SHORT_SHA}

.PHONY: all image test lint snyk demo image

all: image test lint snyk demo

image:
	${PWD}/build_test.sh -bo

test:
	${PWD}/build_test.sh

lint:
	docker run --rm --volume "${PWD}:/app" cyberdojo/rubocop --raise-cop-error

snyk-container: image
	snyk container test ${IMAGE_NAME}
        --file=Dockerfile
        --json-file-output=snyk.container.scan.json
        --policy-path=.snyk

demo:
	${PWD}/demo.sh
