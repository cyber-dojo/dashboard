/*global cd*/
'use strict';

cd.urlParam = (name, fallBack) => {
  const params = new URLSearchParams(window.location.search);
  const value = params.get(name) || fallBack;
  return (value === null) ? fallBack : value.toString();
};
