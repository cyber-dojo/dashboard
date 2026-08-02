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

# The app owns its prefix: nginx passes /dashboard/... through untouched, so
# there is one mount, and SCRIPT_NAME tells the app where it is mounted.
run Rack::URLMap.new('/dashboard' => app)
