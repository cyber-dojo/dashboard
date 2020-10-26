/*global cd,$*/
'use strict';
$(() => {

  const groupId = cd.urlParam('id');

  const cssId = 'traffic-lights2';
  const $lights = $(`#${cssId}`);
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
      cd.pieChart($(`#${cssId} .pie`));
      $('.scroll-handle').scrollIntoView();
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
    $tBody.empty();
    Object.keys(avatars).forEach(function(groupIndex) {
      const avatar = avatars[groupIndex];
      const kataId = avatar['kata_id'];
      const $tr = $('<tr>');
      const $fixedColumn = $('<div>', { class:'fixed-column' });
      $tBody.append($tr.append($('<th>').append($fixedColumn)));
      const args = appendAllLights($tr, kataId, groupIndex, avatar['lights']);
      $fixedColumn.append($avatarImage(kataId, groupIndex));
      $fixedColumn.append($trafficLightsPieChart(args.counts, kataId));
      $fixedColumn.append($trafficLightsCount(args));
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
    cd.setupAvatarNameHoverTip($img, groupIndex);
    return $img;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const appendAllLights = ($tr, kataId, groupIndex, minutes) => {
    // minutes = {
    //    "0": [ {...},{...},{...} ],
    //    "1": { "collapsed":525 },
    //  "526": [ {...},{...} ]
    // }
    const args = {
      'number':1,      // the UI traffic-light number
      'wasIndex':0,    // the previously displayed element's git tag
      'parity':'even', // for columns
      'counts':{}      // of each traffic-light colour
    };
    Object.keys(minutes).forEach(function(minute) {
      const $td = $('<td>', { class:`${args.parity} column` });
      const $minuteBox = $('<div>', { class:'minute-box' });
      const lights = minutes[minute];
      appendOneMinutesLights($minuteBox, kataId, groupIndex, lights, args);
      $td.append($minuteBox);
      $tr.append($td);
    });
    $tr.append($('<td>', { class:'scroll-handle' }));
    return args;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const appendOneMinutesLights = ($minuteBox, kataId, groupIndex, lights, args) => {
    if (lights.collapsed) {            // eg lights === { "collapsed":525 }
      $minuteBox.append($('<span>', { class:'collapsed-columns' }));
    } else {                           // eg lights === [ {"index":3,"colour":"red"},{...} ]
      lights.forEach(function(light) { // eg light === {"index":3,"colour":"red"}
        const colour = light.colour;
        const nowIndex = light.index;
        const $light = $('<img>', {
            src:`/images/traffic-light/${colour}.png`,
          class:'diff-traffic-light',
            alt:`${colour} traffic-light`
        });
        cd.setupTrafficLightTip($light, kataId, groupIndex, args.wasIndex, nowIndex, colour, args.number);
        args.number += 1;
        args.wasIndex = nowIndex;
        args.lastColour = colour; // (for colour of traffic-lights-count)
        //TODO: ? light.predicted
        //TODO: ? light.reverted
        $minuteBox.append($light);
        unless(args.counts[colour], () => args.counts[colour] = 0);
        args.counts[colour] += 1;
      }); // forEach
      args.parity = (args.parity === 'odd' ? 'even' : 'odd');
    } // else
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const $trafficLightsPieChart = (counts, kataId) => {
    // Here be dragons...
    // Sizing a canvas appears to be horribly delicate.
    // See https://www.chartjs.org/docs/latest/general/responsive.html
    // The code below works, and gives a circular 26px diameter pie-chart :-)
    // All attempts to convert to $('<div>',{...}) syntax failed.
    // jQuery appears to change the width/height attributes and
    // to also put them inside a style attribute.
    // All attempts to use a .scss file also failed.
    return '' +
      `<div
         class="pie-chart-wrapper"
         width="26px"
         height="26px">
         <canvas
           class="pie"
           data-red-count="${counts.red || 0}"
           data-amber-count="${counts.amber || 0}"
           data-green-count="${counts.green || 0}"
           data-timed-out-count="${counts.timedOut || 0}"
           data-key="${kataId}"
           width="26px"
           height="26px">
         </canvas>
       </div>`;
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const $trafficLightsCount = (args) => {
    const $count = $('<div>', {
      class:`traffic-light-count ${args.lastColour}`
    }).text(args.number);
    cd.setupTrafficLightCountHoverTip($count, args.counts);
    return $count;
  };

});
