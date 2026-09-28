
dashboard_image:
	@${PWD}/dashboard/bin/build_image.sh server

dashboard_test_server:
	@${PWD}/dashboard/bin/run_tests.sh server

dashboard_coverage_server:
	@${PWD}/dashboard/bin/check_coverage.sh server

dashboard_rubocop_lint:
	@${PWD}/dashboard/bin/rubocop_lint.sh

dashboard_snyk_container_scan:
	@${PWD}/dashboard/bin/snyk_container_scan.sh

dashboard_demo: dashboard_image
	@${PWD}/dashboard/bin/demo.sh

dashboard_demo_data:
	@${PWD}/dashboard/bin/demo_data.sh
