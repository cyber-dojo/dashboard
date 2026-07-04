require_relative 'app_base'
require_relative 'prober'
require_relative 'helpers/gatherer'
require_relative 'helpers/avatars_progress'

class App < AppBase
  def initialize(externals)
    super
    @externals = externals
  end

  attr_reader :externals

  get_delegate(Prober, :alive?)
  get_delegate(Prober, :ready?)
  get_delegate(Prober, :sha)

  get '/show/:id', provides: [:html] do
    @id = params[:id]
    resolve_group_and_tabs
    respond_to do |wants|
      wants.html do
        erb :show
      end
    end
  end

  get '/heartbeat/:id', provides: [:json] do
    # Process all traffic-lights into minute columns here in Ruby
    # which can easily handle integers (unlike JS).
    # Then let browser do all rendering in JS.
    respond_to do |wants|
      wants.json do
        gather
        time_ticks = modified(@time_ticks)
        avatars = altered(@all_indexes, @gapped)
        json({ time_ticks: time_ticks, avatars: avatars })
      end
    end
  end

  get '/diff_summary', provides: [:json] do
    respond_to do |wants|
      wants.json do
        id = params[:id]
        was_index = params[:was_index].to_i
        now_index = params[:now_index].to_i
        json({ diff_summary: externals.saver.diff_summary(id, was_index, now_index) })
      end
    end
  end

  get '/progress/:id', provides: [:json] do
    respond_to do |wants|
      wants.json do
        json(katas: avatars_progress)
      end
    end
  end

  private

  helpers AvatarsProgressHelper
  helpers GathererHelper

  # Resolves the shared id in @id (a kata, group or cluster id) up to the
  # topmost entity and decides how the page renders it:
  # - @group_id is the child group whose avatars are shown first (cd.groupId()).
  # - @tabs is one entry per child group of a cluster (id + LTF display_name);
  #   it is empty for a standalone group, so today's single view is unchanged.
  # A cluster shows one tab per child group (duplicate-LTF children each get
  # their own tab); the given id picks the active child (kata/group -> its own
  # group; a bare cluster id -> the first child).
  def resolve_group_and_tabs
    chain = externals.saver.id_chain(@id)
    cluster = chain.find { |entry| entry['type'] == 'cluster' }
    group   = chain.find { |entry| entry['type'] == 'group' }
    if cluster
      groups = externals.saver.cluster_manifest(cluster['id'])['groups']
      @tabs = groups.map do |group_id, manifest|
        { 'id' => group_id, 'display_name' => manifest['display_name'] }
      end
      @group_id = group ? group['id'] : @tabs.first['id']
    else
      @tabs = []
      @group_id = group ? group['id'] : @id
    end
  rescue StandardError
    # Resolving is best-effort: if the id resolves to nothing (or the saver is
    # unreachable), render as a standalone group keyed on the given id - today's
    # behaviour - and let the per-child fetches surface any error, as before.
    @tabs = []
    @group_id = @id
  end

  def altered(indexes, gapped)
    indexes.to_h do |kata_id, group_index|
      [group_index, {
        kata_id: kata_id,
        lights: lights_json(gapped[kata_id])
      }]
    end
  end

  def lights_json(minutes)
    # eg minutes = {
    #     "0": [ L,L,L ],
    #     "1": { "collapsed":525 },
    #   "526": [ L,L ]
    # }
    minutes.transform_values { |value| minute_json(value) }
  end

  def minute_json(minute)
    if collapsed?(minute)
      minute
    else
      minute.map { |light| light_json(light) }
    end
  end

  def collapsed?(section)
    section.is_a?(Hash) # lights are in an Array
  end

  def light_json(light)
    element = {
      previous_index: light.previous_index,
      index: light.index,
      major_index: light.major_index,
      minor_index: light.minor_index,
      colour: light.colour,
      time: light.time_a
    }
    element['predicted'] = light.predicted if light.predicted && light.predicted != 'none'
    element['revert'] = light.revert if light.revert
    element['checkout'] = light.checkout if light.checkout
    element['filename'] = light.filename if light.filename
    element
  end

  def modified(ticks)
    ticks.transform_values do |v|
      dhm(v)
    end
  end

  def dhm(value)
    if value.is_a?(Integer)
      time_tick(value)
    else
      value # Hash === collapsed columns
    end
  end

  def time_tick(seconds)
    # Avoiding Javascript integer arithmetic
    minutes = (seconds / 60) % 60
    hours   = (seconds / 60 / 60) % 24
    days    = (seconds / 60 / 60 / 24)
    [days, hours, minutes]
  end
end
