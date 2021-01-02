/*global cd,$*/
'use strict';
(() => {

  cd.setupAvatarNameHoverTip = ($avatar, prefix, avatarIndex, suffix) => {
    setTip($avatar, () => {
      $.getJSON('/images/avatars/names.json', '', (avatarsNames) => {
        const avatarName = avatarsNames[avatarIndex];
        const tip = `${prefix}${avatarName}${suffix}`;
        showHoverTip($avatar, tip);
      });
    });
  };

  // - - - - - - - - - - - - - - - - - - - -
  cd.setupTrafficLightTip = ($light, colour, avatarIndex, kataId, wasIndex, nowIndex) => {
    setTip($light, () => {
      const args = { id:kataId, was_index:wasIndex, now_index:nowIndex };
      cd.getJSON('differ', 'diff_summary', args, (diffSummary) => {
        const $tip = $trafficLightTip($light, colour, nowIndex, avatarIndex, diffSummary);
        cd.showHoverTip($light, $tip);
      });
    });
  };

  cd.showHoverTip = (node, tip, where) => {
    if (where === undefined) {
      where = {};
    }
    if (where.my === undefined) { where.my = 'top'; }
    if (where.at === undefined) { where.at = 'bottom'; }
    if (where.of === undefined) { where.of = node; }

    if (!node.attr('disabled')) {
      if (!node.hasClass('mouse-has-left')) {
        // position() is the jQuery UI plug-in
        // https://jqueryui.com/position/
        const hoverTip = $('<div>', {
          'class': 'hover-tip'
        }).html(tip).position({
          my: where.my,
          at: where.at,
          of: where.of,
          collision: 'flip'
        });
        hoverTipContainer().html(hoverTip);
      }
    }
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $trafficLightTip = ($light, colour, index, avatarIndex, diff) => {
    const $holder = $(document.createDocumentFragment());
    $holder.append($trafficLightSummary($light, colour, index, avatarIndex));
    $holder.append($diffLinesTable(diff));
    return $holder;
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $trafficLightSummary = ($light, colour, index, avatarIndex) => {
    const $tr = $('<tr>');
    $tr.append($avatarImageTd(avatarIndex));
    $tr.append($trafficLightCountTd(colour, index));
    $tr.append($trafficLightImageTd(colour));
    return $('<table>').append($tr);
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $avatarImageTd = (avatarIndex) => {
    const $td = $('<td>');
    if (avatarIndex != '') {
      const $img = $('<img>', {
          src: `/images/avatars/${avatarIndex}.jpg`,
        class: 'traffic-light-diff-tip-avatar-image'
      });
      $td.append($img);
    }
    return $td;
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $trafficLightCountTd = (colour, index) => {
    const $count = $('<span>', {
      class:`traffic-light-count ${colour}`
    }).text(index);
    return $('<td>').append($count);
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $trafficLightImageTd = (colour) => {
    const $img = $('<img>', {
        src:`/images/traffic-light/${colour}.png`,
      class:'traffic-light-diff-tip-traffic-light-image'
    });
    return $('<td>').append($img);
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $diffLinesTable = (diffs) => {
    const $table = $('<table>', { class:'filenames' });
    const $tr = $('<tr>');
    // column icons
    $tr.append($linesCountIconTd('deleted', '&mdash;'));
    $tr.append($linesCountIconTd('added', '+'));
    $tr.append($linesCountIconTd('same', '='));
    $tr.append($('<td>'));
    $tr.append($('<td>'));
    $table.append($tr);
    // cyber-dojo.sh cannot be deleted so there is always one file
    const filenames = diffs.map(diff => diffFilename(diff));
    sortedFilenames(filenames).forEach(filename => {
      const fileDiff = diffs.find(diff => diffFilename(diff) === filename);
      const $tr = $('<tr>');
      $tr.append($lineCountTd('deleted', fileDiff));
      $tr.append($lineCountTd('added', fileDiff));
      $tr.append($lineCountTd('same', fileDiff));
      $tr.append($diffTypeTd(fileDiff));
      $tr.append($diffFilenameTd(fileDiff));
      $table.append($tr);
    });
    return $table;
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $linesCountIconTd = (type, glyph) => {
    const $icon = $('<div>', {
      class:`diff-line-count-icon ${type}`
    }).html(glyph);
    return $('<td>').append($icon);
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $lineCountTd = (type, file) => {
    const lineCount = file.line_counts[type];
    const css = lineCount > 0 ? type : '';
    const $count = $('<div>', {
      class:`diff-line-count ${css}`,
      disabled:'disabled'
    });
    $count.html(lineCount > 0 ? lineCount : '&nbsp;');
    return $('<td>').append($count);
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $diffTypeTd = (diff) => {
    const $type = $('<div>', {
      class:`diff-type-marker ${diff.type}`
    });
    return $('<td>').append($type);
  };

  // - - - - - - - - - - - - - - - - - - - -
  const $diffFilenameTd = (diff) => {
    const $filename = $('<div>', { class:`diff-filename ${diff.type}` });
    $filename.text(diffFilename(diff));
    return $('<td>').append($filename);
  };

  // - - - - - - - - - - - - - - - - - - - -
  const diffFilename = (diff) => {
    if (diff.type === 'deleted') {
      return diff.old_filename;
    } else {
      return diff.new_filename;
    }
  };

  // - - - - - - - - - - - - - - - - - - - -
  const sortedFilenames = (filenames) => {
    const sliced = filenames.slice();
    sliced.sort(orderer);
    return sliced;
  };

  const orderer = (lhs, rhs) => {
    const lhsFileCat = fileCategory(lhs);
    const rhsFileCat = fileCategory(rhs);
    if (lhsFileCat < rhsFileCat)      { return -1; }
    else if (lhsFileCat > rhsFileCat) { return +1; }
    else if (lhs < rhs)               { return -1; }
    else if (lhs > rhs)               { return +1; }
    else                              { return  0; }
  };

  const fileCategory = (filename) => {
    let category = undefined;
    if (isHighlight(filename))    { category = 1; }
    else if (isSource(filename))  { category = 2; }
    else                          { category = 3; }
    // Special cases
    if (filename === 'readme.txt')    { category = 0; } // [A]
    if (filename === 'cyber-dojo.sh') { category = 3; } // [B]
    return category;
    // [A] Always at the top
    // [B] Shell test frameworks (eg shunit2) use .sh extension
    //     but cyber-dojo.sh is not a user source file.
  };

  const isHighlight = (filename) => {
    // cd.highlightFilenames() is in views/manifest.erb
    return cd.highlightFilenames().includes(filename);
  };

  const isSource = (filename) => {
    // cd.extensionFilenames() is in views/manifest.erb
    return cd.extensionFilenames().find(ext => filename.endsWith(ext));
  };

  // - - - - - - - - - - - - - - - - - - - -
  cd.setupTrafficLightCountHoverTip = ($count, counts) => {
    const reds = counts.red || 0;
    const ambers = counts.amber || 0;
    const greens = counts.green || 0;
    const timeOuts = counts.timed_out || 0;

    const tr = (s) => `<tr>${s}</tr>`;
    const td = (s) => `<td>${s}</td>`;
    const trLight = (colour, count) => {
      return tr(td('<img' +
                   " class='traffic-light-diff-tip-traffic-light-image'" +
                   ` src='/images/traffic-light/${colour}.png'>`) +
                td(`<div class='traffic-light-diff-tip-tag ${colour}'>` +
                   count +
                   '</div>'));
    };
    let html = '';
    html += '<table>';
    html += trLight('red', reds);
    html += trLight('amber', ambers);
    html += trLight('green', greens);
    if (timeOuts > 0) {
      html += trLight('timed_out', timeOuts);
    }
    html += '</table>';

    cd.createTip($count, html);
  };

  // - - - - - - - - - - - - - - - - - - - -
  cd.createTip = (element, tip) => {
    setTip(element, () => {
      showHoverTip(element, tip);
    });
  };

  // - - - - - - - - - - - - - - - - - - - -
  const setTip = (node, setTipCallBack) => {
    // The speed of the mouse could exceed
    // the speed of the getJSON callback...
    // The mouse-has-left attribute caters for this.
    node.mouseenter(() => {
      node.removeClass('mouse-has-left');
      setTipCallBack();
    });
    node.mouseleave(() => {
      node.addClass('mouse-has-left');
      hoverTipContainer().empty();
    });
  };

  // - - - - - - - - - - - - - - - - - - - -
  const showHoverTip = ($node, tip) => {
    if (!$node.attr('disabled')) {
      if (!$node.hasClass('mouse-has-left')) {
        const hoverTip = $('<div>', {
          class:'hover-tip'
        }).html(tip).position({
          my: 'left top+50',
          at: 'bottom right',
          of: $node,
          collision: 'flip'
        });
        hoverTipContainer().html(hoverTip);
      }
    }
  };

  // - - - - - - - - - - - - - - - - - - - -
  const hoverTipContainer = () => {
    return $('#hover-tip-container');
  };

})();
