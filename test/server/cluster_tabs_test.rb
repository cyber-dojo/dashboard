require_relative 'test_base'

class ClusterTabsTest < TestBase

  # Cluster eyxahp is baked into the saver test data by
  # bin/create_cluster_data.sh and tar-piped in by copy_in_saver_test_data().
  # It has three child groups (one per LTF), in this manifest order:
  #   8qTubq "Bash, bats"      (first)
  #   4tSCxB "Python, pytest"
  #   5NjQeF "Ruby, MiniTest"
  CLUSTER_ID = 'eyxahp'

  test 'c1u5b1', %w(
  | a bare cluster id resolves up to the cluster: the show page renders
  | one tab per child group, first child active by default (line 83 nil-side)
  ) do
    html = show_html(CLUSTER_ID)
    assert_includes html, 'id="cluster-tabs"', html
    assert_includes html, 'data-group-id="8qTubq"', html
    assert_includes html, 'data-group-id="4tSCxB"', html
    assert_includes html, 'data-group-id="5NjQeF"', html
    assert_includes html, 'Bash, bats', html
    assert_includes html, 'Python, pytest', html
    assert_includes html, 'Ruby, MiniTest', html
    assert_equal '8qTubq', active_tab_id(html), html
  end

  test 'c1u5b2', %w(
  | a non-first child-group id inside a cluster resolves up to the cluster,
  | and that given child is the active tab (line 83 group-present side)
  ) do
    html = show_html('5NjQeF')
    assert_includes html, 'id="cluster-tabs"', html
    assert_equal '5NjQeF', active_tab_id(html), html
  end

  test 'c1u5b3', %w(
  | a standalone group id (in no cluster) renders no cluster tabs (else branch)
  ) do
    html = show_html('LyQpFr')
    refute_includes html, 'id="cluster-tabs"', html
  end

  private

  # GETs /show/<id> as html, asserts a 200, and returns the response body.
  def show_html(id)
    get "/show/#{id}", {}, { 'HTTP_ACCEPT' => 'text/html' }
    assert status?(200), "status=#{status}"
    last_response.body
  end

  # The group id of the tab currently marked cluster-tab-active, or nil.
  def active_tab_id(html)
    m = html.match(/cluster-tab-active"\s*data-group-id="([^"]+)"/m)
    m && m[1]
  end
end
