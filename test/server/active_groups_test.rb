require_relative 'test_base'
require 'json'
require 'net/http'

class ActiveGroupsTest < TestBase

  # Cluster vntRcc is baked into the saver test data (see cluster_tabs_test.rb);
  # every one of its three child groups has avatars with traffic-lights.
  BAKED_CLUSTER_ID = 'vntRcc'
  BAKED_CHILD_IDS = %w[9aZUWE jUgkhB 9bYWLV].freeze
  # A standalone group (in no cluster), also baked in.
  STANDALONE_GROUP_ID = 'LyQpFr'

  # - - - - - - - - - - - - - - - - -

  test 'a6t1v1', %w(
  | GET /active_groups reports, per child group of a cluster, whether it has
  | any avatar with a non-creation event; a child that has only been joined
  | (no test run) is reported false, a child with a run is reported true
  ) do
    cluster_id = create_cluster(%w[LTF-A LTF-B])
    active_child, inactive_child = child_group_ids(cluster_id)
    give_traffic_light(join_avatar(active_child))
    join_avatar(inactive_child) # joined only - no run, so no traffic-light

    active = get_active_groups(cluster_id)
    assert_equal({ active_child => true, inactive_child => false }, active, active)
  end

  # - - - - - - - - - - - - - - - - -

  test 'a6t1v2', %w(
  | GET /active_groups for a cluster whose every child has traffic-lights
  | reports every child true
  ) do
    active = get_active_groups(BAKED_CLUSTER_ID)
    assert_equal BAKED_CHILD_IDS.to_h { |id| [id, true] }, active, active
  end

  # - - - - - - - - - - - - - - - - -

  test 'a6t1v3', %w(
  | GET /active_groups for a standalone group (in no cluster) reports nothing,
  | since a standalone group has no tabs to rotate through
  ) do
    assert_equal({}, get_active_groups(STANDALONE_GROUP_ID), :standalone)
  end

  private

  # GETs /active_groups/<id> as json, asserts 200, and returns the parsed body.
  def get_active_groups(id)
    get "/active_groups/#{id}", {}, { 'HTTP_ACCEPT' => 'application/json' }
    assert status?(200), "status=#{status}"
    JSON.parse(last_response.body)
  end

  # - - - - - - - - - - - - - - - - -
  # Building saver data live (mirrors bin/create_cluster_kata.rb).

  def create_cluster(display_names)
    manifests = display_names.map { |name| group_manifest(name) }
    saver_post('cluster_create', { manifests: manifests })
  end

  def child_group_ids(cluster_id)
    saver_get('cluster_manifest', { id: cluster_id })['groups'].keys
  end

  def join_avatar(group_id)
    saver_post('group_join', { id: group_id })
  end

  # Runs the kata's tests once (a green traffic-light), giving the avatar a
  # non-creation event. The saver assigns the event's index (head + 1), so no
  # index is sent. laptop_id/tab_seq are the writer's idempotency key the saver
  # now requires on every write.
  def give_traffic_light(kata_id)
    files = saver_get('kata_event', { id: kata_id, index: 0 })['files']
    saver_post('kata_ran_tests', {
                 id: kata_id, files: files,
                 stdout: file('2 tests, 0 failures'), stderr: file(''), status: 0,
                 summary: { 'colour' => 'green', 'predicted' => 'none' },
                 laptop_id: '02cfdffb5c0c31221b837a153d1108e6cd19fd6cef11db27c8457a1e63caf46f',
                 tab_seq: 1
               })
  end

  def group_manifest(display_name)
    {
      'display_name' => display_name,
      'image_name' => 'cyberdojofoundation/bash_bats:53d0c9c',
      'filename_extension' => ['.sh'],
      'tab_size' => 4,
      'exercise' => 'Fizz Buzz',
      'version' => 2,
      'highlight_filenames' => [],
      'max_seconds' => 10,
      'visible_files' => {
        'hiker.sh' => file("echo hello\n"),
        'cyber-dojo.sh' => file("./hiker.sh\n")
      }
    }
  end

  def file(content)
    { 'content' => content, 'truncated' => false }
  end

  # - - - - - - - - - - - - - - - - -

  def saver_get(path, args)
    saver_request(Net::HTTP::Get, path, args)
  end

  def saver_post(path, args)
    saver_request(Net::HTTP::Post, path, args)
  end

  def saver_request(method_class, path, args)
    host = ENV.fetch('CYBER_DOJO_SAVER_HOSTNAME', 'saver')
    port = ENV.fetch('CYBER_DOJO_SAVER_PORT', 4537).to_i
    uri = URI("http://#{host}:#{port}/#{path}")
    req = method_class.new(uri)
    req.content_type = 'application/json'
    req.body = JSON.generate(args)
    response = Net::HTTP.start(host, port) { |http| http.request(req) }
    JSON.parse(response.body)[path.to_s]
  end
end
