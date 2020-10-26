/*global cd,$*/
'use strict';
(() => {

  cd.setupAvatarNameHoverTip = ($element, avatarIndex) => {
    setTip($element, () => {
      $.getJSON('/images/avatars/names.json', {}, (avatarsNames) => {
        const avatarName = avatarsNames[avatarIndex];
        showHoverTip($element, avatarName);
      });
    });
  };

  // - - - - - - - - - - - - - - - - - - - -

  cd.setupTrafficLightTip = ($light, kataId, avatarIndex, wasIndex, nowIndex, colour, number) => {
    setTip($light, () => {
      const args = { id:kataId, was_index:wasIndex, now_index:nowIndex };
      // This should be $.getJSON but the receiving Rack
      // server currently reads JSON args from the request body.
      $.post('/differ/diff_summary', JSON.stringify(args), (data) => {
        const tip = tipHtml($light, avatarIndex, colour, number, data.diff_summary);
        showHoverTip($light, tip);
      });
    });
  };

  const tipHtml = ($light, avatarIndex, colour, number, diffSummary) => {
    return `<table>
             <tr>
               <td>${avatarImage(avatarIndex)}</td>
               <td><span class="traffic-light-count ${colour}">${number}</span></td>
               <td><img src="/images/traffic-light/${colour}.png"
                      class="traffic-light-diff-tip-traffic-light-image"></td>
             </tr>
           </table>
           ${diffLinesHtmlTable(diffSummary)}`;
  };

  // - - - - - - - - - - - - - - - - - - - -

  const avatarImage = (avatarIndex) => {
    if (avatarIndex === '') {
      return '';
    } else {
      return `<img src="/images/avatars/${avatarIndex}.jpg"
                 class="traffic-light-diff-tip-avatar-image">`;
    }
  };

  // - - - - - - - - - - - - - - - - - - - -

  const diffLinesHtmlTable = (files) => {
    const chunks = $('<table>');
    Object.keys(files).forEach(function(filename) {
      chunks.append(
        `<tr>
          <td>
            <div class="traffic-light-diff-tip-line-count-deleted some button">
              ${files[filename].deleted}
            </div>
          </td>
          <td>
            <div class="traffic-light-diff-tip-line-count-added some button">
              ${files[filename].added}
            </div>
          </td>
          <td>&nbsp;${filename}</td>
        </tr>`
      ); //append
    }); // forEach
    return chunks.get(0).outerHTML;
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

  const showHoverTip = (node, tip) => {
    if (!node.attr('disabled')) {
      if (!node.hasClass('mouse-has-left')) {
        const hoverTip = $('<div>', {
          'class': 'hover-tip'
        }).html(tip).position({
          my: 'top',
          at: 'bottom',
          of: node,
          collision: 'fit'
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
