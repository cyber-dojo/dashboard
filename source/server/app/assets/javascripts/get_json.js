'use strict';
(() => {

  cd.getJSON = (serviceName, path, args, responder) => {
    $.getJSON(`/${serviceName}/${path}`, args, (json) => {
      responder(json[path]);
    });
  };

})();
