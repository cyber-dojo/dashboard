
assets:
	@${PWD}/bin/build_assets.sh

image_server: assets
	@${PWD}/bin/build_image.sh server

test_server:
	@${PWD}/bin/run_tests.sh server

coverage_server:
	@${PWD}/bin/check_coverage.sh server

rubocop_lint:
	@${PWD}/bin/rubocop_lint.sh

snyk_container_scan:
	@${PWD}/bin/snyk_container_scan.sh

demo:
	@${PWD}/bin/demo.sh
