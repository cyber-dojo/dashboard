/*global cd,$*/
'use strict';
$(() => {

  const groupId = cd.urlParam('id');

  const $lights = $('#traffic-lights2');
  const $tHeadTr = $('table thead tr', $lights);
  const $tBody = $('table tbody', $lights);

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.refresh = () => {
    // A public cd.function so its callable from heartbeat() and
    // when auto-refresh/minute-columns checkboxes are clicked.
    const minuteColumns = cd.minuteColumns.isChecked() ? 'true' : 'false';
    const args = `id=${groupId}&minute_columns=${minuteColumns}`;
    const url = `/dashboard/heartbeat?${args}`;
    $.getJSON(url, {}, (data) => {
      refreshTableHeadWith(data.time_ticks);
      refreshTableBodyWith(data.avatars);
    });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const refreshTableHeadWith = (timeTicks) => {
    $tHeadTr.empty();
    if (cd.minuteColumns.isChecked()) {
      $tHeadTr.append($('<tr>')); // to match avatar-image|pie-chart|traffic-light-count
      Object.keys(timeTicks).forEach(function(minutes) { // eg minutes == "1"
        const minute = timeTicks[minutes];               // eg minute  == [days,hours,seconds]
        const $th = $('<th>');
        unless(isCollapsed(minute), () => {
          $th.append($('<div>', { class:'time-tick' }));
          cd.createTip($th, cd.timeTick(minute));
        });
        $tHeadTr.append($th);
      }); // forEach
      $tHeadTr.append($('<th>')); // to match scroll-marker
    }
  };

  const unless = (truth, callBack) => {
    if (!truth) {
      callBack();
    }
  };

  const isCollapsed = (minute) => {
    return !Array.isArray(minute); // eg { "collapsed": 525 }
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const refreshTableBodyWith = (avatars) => {
    //console.log(`avatars ${JSON.stringify(avatars)}`);
    $tBody.empty();
    Object.keys(avatars).forEach(function(groupIndex) {
      const avatar = avatars[groupIndex];
      const kataId = avatar['kata_id'];
      const $tr = $('<tr>');
      const $th = $('<th>');
      const $fixedColumn = $('<div>', { class:'fixed-column' });
      const $pieChart = $emptyPieChart();
      const $trafficLightsCounts = $emptyTrafficLightsCounts();
      $fixedColumn.append($avatarImage(kataId, groupIndex));
      $fixedColumn.append($pieChart);
      $fixedColumn.append($trafficLightsCounts);
      $th.append($fixedColumn);
      $tr.append($th);
      // const counts = appendLights($tr, kataId, avatar['lights']);
      // fillInCounts($pieChart, $trafficLightsCounts, counts)
      $tBody.append($tr);
    }); // forEach
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const $avatarImage = (kataId, groupIndex) => {
    const $img = $('<img>', {
        src:`/images/avatars/${groupIndex}.jpg`,
      class:'avatar-image',
        alt:'avatar image'
    });
    $img.click(() => window.open(cd.reviewUrl(kataId, -1, -1)));
    cd.setupAvatarNameHoverTip($img, '', groupIndex, '');
    return $img;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const $emptyPieChart = () => {
    return $('<div>', { class:'pie-chart-wrapper' });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const $emptyTrafficLightsCounts = () => {
    return $('<div>', { class:'traffic-light-count-wrapper' });
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const appendLights = ($tr, kataId, lights) => {
    // variables for wasIndex, number
    const counts = {};
    //...
    return counts;
  };

});
