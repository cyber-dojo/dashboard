/*global jQuery,cyberDojo*/
'use strict';
var cyberDojo = ((cd, $) => {

  cd.urlParam = (name, fallBack) => {
    const params = new URLSearchParams(window.location.search);
    const value = params.get(name) || fallBack;
    return (value === null) ? fallBack : value.toString();
  };

  return cd;

})(cyberDojo || {}, jQuery);
