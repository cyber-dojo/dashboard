require_relative 'test_base'

class ClusterTabsTest < TestBase

  # Cluster vntRcc is baked into the saver test data by
  # bin/create_cluster_data.sh and tar-piped in by copy_in_saver_test_data().
  # It has three child groups (one per LTF), in this manifest order:
  #   9aZUWE "Bash, bats"      (first)
  #   jUgkhB "Python, pytest"
  #   9bYWLV "Ruby, MiniTest"
  CLUSTER_ID = 'vntRcc'

  test 'c1u5b1', %w(
  | a bare cluster id resolves up to the cluster: the show page renders
  | one tab per child group, first child active by default (line 83 nil-side)
  ) do
    html = show_html(CLUSTER_ID)
    assert_includes html, 'id="cluster-tabs"', html
    assert_includes html, 'data-group-id="9aZUWE"', html
    assert_includes html, 'data-group-id="jUgkhB"', html
    assert_includes html, 'data-group-id="9bYWLV"', html
    assert_includes html, 'Bash, bats', html
    assert_includes html, 'Python, pytest', html
    assert_includes html, 'Ruby, MiniTest', html
    assert_equal '9aZUWE', active_tab_id(html), html
  end

  test 'c1u5b2', %w(
  | a non-first child-group id inside a cluster resolves up to the cluster,
  | and that given child is the active tab (line 83 group-present side)
  ) do
    html = show_html('9bYWLV')
    assert_includes html, 'id="cluster-tabs"', html
    assert_equal '9bYWLV', active_tab_id(html), html
  end

  test 'c1u5b3', %w(
  | a standalone group id (in no cluster) renders no cluster tabs (else branch)
  ) do
    html = show_html('LyQpFr')
    refute_includes html, 'id="cluster-tabs"', html
  end

  test 'c1u5b4', %w(
  | a group_id query param inside a cluster selects that child as the active
  | tab, overriding the bare-cluster-id default of the first child
  ) do
    html = show_html(CLUSTER_ID, group_id: 'jUgkhB')
    assert_includes html, 'id="cluster-tabs"', html
    assert_equal 'jUgkhB', active_tab_id(html), html
  end

  test 'c1u5b5', %w(
  | a group_id query param that names no child of the cluster is ignored:
  | the active tab falls back to the first child (never an absent tab)
  ) do
    html = show_html(CLUSTER_ID, group_id: 'nosuch')
    assert_includes html, 'id="cluster-tabs"', html
    assert_equal '9aZUWE', active_tab_id(html), html
  end

  private

  # GETs /show/<id> as html, asserts a 200, and returns the response body.
  def show_html(id, params = {})
    get "/show/#{id}", params, { 'HTTP_ACCEPT' => 'text/html' }
    assert status?(200), "status=#{status}"
    last_response.body
  end

  # The group id of the tab currently marked cluster-tab-active, or nil.
  def active_tab_id(html)
    m = html.match(/cluster-tab-active"\s*data-group-id="([^"]+)"/m)
    m && m[1]
  end
end
