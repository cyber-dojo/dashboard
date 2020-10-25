/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.showReviewUrl = (id, wasIndex, nowIndex) => {
    return `/review/show/${id}` +
      `?was_index=${wasIndex}` +
      `&now_index=${nowIndex}`;
  };

  return cd;

})(cyberDojo || {}, jQuery);
