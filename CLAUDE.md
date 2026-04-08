
When running a cyber-dojo practice session for many people, you often end up with people just trying it out, i.e., getting an animal and hitting test once, before then either pairing up, mobbing or soloing under another animal. When doing a review this can leave the dashboard with a lot of single-commit animals to wade through.

Please provide ways to sort the animal rows by:
- animal name (current default)
- number of traffic-lights

The dashboard has a auto refresh checkbox, so when a page auto-refreshes, the currently
selected sort criteria must be retained.

## What was implemented

The table's fixed header cell (top-left, sticky) now contains two clickable sort widgets:

- **Name ▲/▼** — sorts rows by avatar name (group index), ascending or descending
- **Lights ▲/▼** — sorts rows by total RAG traffic-light count, ascending or descending

Clicking the active widget toggles its direction (▲↔▼). Clicking the inactive widget switches to it (defaulting to ascending).

### Key files changed

- `source/server/app/assets/javascripts/refresh.js`
  - `sortState` object holds `column` ('name'|'lights') and `direction` ('asc'|'desc'). Initial column read from `?sort_by=` URL param.
  - `$sortHeaderDiv()` builds the two clickable widgets and re-renders on each refresh.
  - `refreshTableHeadWith()` always adds the sort header `<th>` as the first cell.
  - `sortedAvatarKeys()` sorts avatar keys by the active column and direction before rendering rows.
  - `totalLightCount()` counts non-collapsed RAG lights per avatar for the lights sort.
- `source/server/app/assets/stylesheets/fixed-column.scss` — CSS for `.sort-header` and `.sort-widget` / `.sort-active`.
- `source/server/app/assets/javascripts/pre-built-app.js` — rebuilt via `make assets` (Docker).
- `source/server/app/assets/stylesheets/pre-built-app.css` — rebuilt via `make assets` (Docker).

## Datetime in event hovertips

Each traffic-light event's hovertip now shows a datetime row (row 2) immediately below the avatar/count/colour row (row 1), in the format `CCYY:MM:DD HH:MM:SS`.

### Key files changed

- `source/server/app/app.rb` — `light_json` now includes `time: light.time_a` in the JSON payload. `light.time_a` returns the `[year,month,day,hour,min,sec,usec]` array stored by the saver.
- `source/server/app/assets/javascripts/hover_tips.js`
  - `$trafficLightSummary()` appends a second `<tr>` with a `<td colspan=4 class="datetime">` when `light.time` is present.
  - `formatDateTime(timeA)` zero-pads each component and renders as `CCYY:MM:DD HH:MM:SS`.
- `source/server/app/assets/stylesheets/lib/hover-tip.scss` — `.hover-tip .datetime` rule (small, grey, matching `.mini-text`).
- `source/server/app/assets/javascripts/pre-built-app.js` — rebuilt via `make assets` (Docker).
- `source/server/app/assets/stylesheets/pre-built-app.css` — rebuilt via `make assets` (Docker).
