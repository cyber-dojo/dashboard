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
      $tHeadTr.append($('<th>')); // to match avatar-image|pie-chart|traffic-light-count
      Object.keys(timeTicks).forEach(function(minutes) { // eg minutes == "1"
        const minute = timeTicks[minutes];               // eg minute == [ days,hours,seconds ]
        const $th = $('<th>');                           // or minute == { "collapsed":525 }
        unless(minute.collapsed, () => {
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
      const counts = appendAllLights($tr, groupIndex, kataId, avatar['lights']);
      fillInCounts($pieChart, $trafficLightsCounts, counts)
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

  const appendAllLights = ($tr, groupId, kataId, minutes) => {
    // minutes = {
    //    "0": [ {...},{...},{...} ],
    //    "1": { "collapsed":525 },
    //  "526": [ {...},{...} ]
    // }
    const args = {
      'number':1,    // the UI traffic-light number
      'wasIndex':0   // the previously displayed element's git tag
    };
    let parity = 'even';
    const counts = { 'red':0, 'amber':0, 'green':0, 'timed_out':0 };
    Object.keys(minutes).forEach(function(minute) {
      const $td = $('<td>', { class:`${parity} column` });
      const $minuteBox = $('<div>', { class:'minute-box' });
      const lights = minutes[minute];
      appendOneMinutesLights($minuteBox, groupId, kataId, lights, counts, args);
      $td.append($minuteBox);
      $tr.append($td);
      parity = nextParity(parity);
    });
    //TODO: append <td> scroll-handle
    return counts;
  };

  const nextParity = (s) => s === 'odd' ? 'even' : 'odd';

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const appendOneMinutesLights = ($minuteBox, groupId, kataId, lights, counts, args) => {
    if (lights.collapsed) { // eg lights === { "collapsed":525 }
      $minuteBox.append($('<span>', { class:'collapsed-multi-gap' }));
    } else { // eg lights === [ {"index":3,"colour":"red"},{...} ]
      lights.forEach(function(light) { // eg light === {"index":3,"colour":"red"}
        const colour = light.colour;
        const nowIndex = light.index;
        const $light = $('<img>', {
            src:`/images/traffic-light/${colour}.png`,
          class:'diff-traffic-light',
            alt:`${colour} traffic-light`
        });
        //TODO: Setup traffic-light diff-hover-tip
        args.number += 1;
        args.wasIndex = nowIndex;
        args.lastColour = colour; // (for colour of traffic-lights-count)
        //TODO: predicted?
        //TODO: reverted?
        $minuteBox.append($light);
      });

      //counts[colour] += 1;
    }
    return args;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const fillInCounts = ($pieChart, $trafficLightsCounts, counts) => {
  };

});
