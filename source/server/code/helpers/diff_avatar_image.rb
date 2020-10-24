# frozen_string_literal: true
require_relative '../models/avatars'

module AppHelpers # mix-in

  def diff_avatar_image(kata_id, avatar_index, index)
    #apostrophe = '&#39;'
    #avatar_name = Avatars.names[avatar_index]
    "<div class='avatar-image'" +
        " data-id='#{kata_id}'" +
        " data-index='#{index}'>" +
        "<img src='/images/avatars/#{avatar_index}.jpg'>" +
     '</div>'
  end

end
