/*global cd,$*/
'use strict';
$(() => {

  const groupId = cd.urlParam('id');

  const $lights = $('#traffic-lights2');
  const $tHeadTr = $('table thead tr', $lights);
  const $tBody = $('table tbody', $lights);

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  cd.refresh = () => {
    // A public cd.function so its callable from heartbeat()
    // and also when auto-refresh/minute-columns checkboxes
    // are clicked.
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
    //alert(`avatars ${JSON.stringify(avatars)}`);
    $tBody.empty();
    Object.keys(avatars).forEach(function(groupIndex) {
      const avatar = avatars[groupIndex];
      const kataIndex = avatar['kata_id'];
      const $tr = $('<tr>');
      const $th = $('<th>');
      const $fixedColumn = $('<div>', { class:'fixed-column' });
      $fixedColumn.append($avatarImage(groupIndex));
      // $fixedColumn.append( pie-chart );
      // $fixedColumn.append( traffic-light-count );
      $th.append($fixedColumn);
      $tr.append($th);
      $tBody.append($tr);
      // update lights === avatar['lights']
    }); // forEach
  };

  //- - - - - - - - - - - - - - - - - - - - - - - - - - -

  const $avatarImage = (groupIndex) => {
    const $img = $('<img>', {
        src:`/images/avatars/${groupIndex}.jpg`,
      class:'avatar-image',
        alt:'avatar image'
    });
    cd.setupAvatarNameHoverTip($img, '', groupIndex, '');
    return $img;
  };


});
