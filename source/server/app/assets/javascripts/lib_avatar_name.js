/*global cd,$*/
'use strict';
(() => {

  let avatarNamesCache = undefined;

  cd.lib.avatarName = (n) => {
    if (avatarNamesCache === undefined) {
      $.ajax({
              type: 'GET',
               url: '/images/avatars/names.json',
          dataType: 'json',
             async: false,
           success: (avatarsNames) => {
             avatarNamesCache = avatarsNames;
           }
      });
    }
    return avatarNamesCache[n];
  };

})();
