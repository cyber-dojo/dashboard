/*global cd*/
'use strict';

cd.reviewUrl = (kataId, wasIndex, nowIndex) => {
  return `/review/show/${kataId}` +
    `?was_index=${wasIndex}` +
    `&now_index=${nowIndex}`;
};
