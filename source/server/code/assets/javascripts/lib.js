/*global cd,$*/
'use strict';
(() => {

  cd.lib = {};

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Older katas did not distinguish between
  //   - an auto-revert, from an incorrect test prediction
  //   - a [checkout], from the review page.
  // Both were light.revert == [id,index]

  cd.lib.hasPrediction = (light) => light.predicted != undefined && light.predicted != 'none';
  cd.lib.isRevert = (light) => light.revert != undefined;
  cd.lib.isCheckout = (light) => light.checkout != undefined;

})();
