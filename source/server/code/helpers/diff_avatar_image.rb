# frozen_string_literal: true
require_relative '../models/avatars'

module AppHelpers # mix-in

  def diff_avatar_image(kata_id, avatar_index, index)
    apostrophe = '&#39;'
    avatar_name = Avatars.names[avatar_index]
    "<div class='avatar-image'" +
        " data-tip='review #{avatar_name}#{apostrophe}s<br/>current code'" +
        " data-id='#{kata_id}'" +
        " data-index='#{index}'>" +
        "<img src='/avatar/image/#{avatar_index}'" +
            " alt='#{avatar_name}'/>" +
     '</div>'
  end

end
