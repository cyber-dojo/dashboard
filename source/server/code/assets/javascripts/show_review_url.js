'use strict';

cd.showReviewUrl = (id, wasIndex, nowIndex) => {
  return `/review/show/${id}` +
    `?was_index=${wasIndex}` +
    `&now_index=${nowIndex}`;
};
