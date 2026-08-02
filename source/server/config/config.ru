$stdout.sync = true
$stderr.sync = true

if ENV['CYBER_DOJO_PROMETHEUS'] === 'true'
  require 'prometheus/middleware/collector'
  require 'prometheus/middleware/exporter'
  use Prometheus::Middleware::Collector
  use Prometheus::Middleware::Exporter
end

require_relative '../dashboard/app'
require_relative '../dashboard/externals'
externals = DashboardApp::Externals.new
app = DashboardApp::App.new(externals)

# Mounted at both prefixes for the cutover. nginx currently rewrites
# /dashboard/... down to /..., which the / mount serves exactly as before;
# once that rewrite goes, the intact path arrives and the /dashboard mount
# serves it. The / mount is deleted last, so nginx and the app never have to
# be released together.
run Rack::URLMap.new('/' => app, '/dashboard' => app)
