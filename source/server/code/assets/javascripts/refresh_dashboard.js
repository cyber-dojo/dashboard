/*global jQuery,cyberDojo*/
'use strict';
$(() => {

  const groupId = cd.urlParam('id');

  const $lights = $('#traffic-lights2');
  const $tHeadTr = $('table thead tr', $lights);
  const $tBody = $('table tbody', $lights);

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.refreshDashboard = (forced) => {
    // A public cd.function so its callable from heartbeat()
    // and also when auto-refresh/minute-columns checkboxes
    // are clicked.
    if (cd.autoRefresh.isChecked() || forced) {
      const minuteColumns = cd.minuteColumns.isChecked() ? 'true' : 'false';
      const args = `id=${groupId}&minute_columns=${minuteColumns}`;
      const url = `/dashboard/heartbeat?${args}`;
      $.getJSON(url, {}, (data) => {
        refreshTableHeadWith(data.time_ticks);
        refreshTableBodyWith(data.avatars);
      });
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const refreshTableHeadWith = (timeTicks) => {
    $tHeadTr.empty();
    if (cd.minuteColumns.isChecked()) {
      $tHeadTr.append($('<tr>')); // to match avatar-image|pie-chart|traffic-light-count
      Object.keys(timeTicks).forEach(function(key) {
        const dhs = timeTicks[key]; // [days,hours,seconds]
        const $th = $('<th>');
        if (Array.isArray(dhs)) {
          $th.append($('<div>', { class:'time-tick' }));
          cd.createTip($th, cd.timeTick(dhs));
        }
        $tHeadTr.append($th);
      }); // forEach
      $tHeadTr.append($('<th>')); // to match scroll-marker
    }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const refreshTableBodyWith = (avatars) => {
    $tBody.empty();
    // Object.keys(avatars).forEach(function(kataId) => {
    //   const avatar = avatars[kataId];
    //   update avatar-image
    //   update pie-chart
    //   update traffic-light-count
    //   update traffic-lights
    // }
  };

});
