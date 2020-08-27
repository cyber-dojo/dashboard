# frozen_string_literal: true
require_relative 'app_base'
require_relative 'dashboard'

class App < AppBase

  def initialize(externals)
    super()
    @externals = externals
  end

  attr_reader :externals

  def dashboard
    Dashboard.new(externals)
  end

  get_probe(:alive?) # curl/k8s
  get_probe(:ready?) # curl/k8s
  get_probe(:sha)    # identity

  # - - - - - - - - - - - - - - - - - - - - -

  get '/show', provides:[:html] do
    respond_to do |format|
      format.html do
        erb:'show'
      end
    end
  end

  private

  def params_args
    symbolized(params)
  end

end
