#!/usr/bin/env bash
# Status line: model │ context tokens │ session cost │ 5h limit │ weekly limit
exec jq -r '
  def num: if type == "number" then . else null end;
  def k: if . == null then "–"
    elif . >= 1000000 then "\(. / 100000 | floor / 10)M"
    elif . >= 1000 then "\(. / 1000 | floor)k"
    else "\(floor)" end;
  def pct: if . == null then "–" else "\(round)%" end;
  def money: (. * 100 | round) as $c
    | "$\($c / 100 | floor).\($c % 100 | tostring | if length < 2 then "0" + . else . end)";
  def reset(fmt):
    if . == null then ""
    elif type == "number" then " ↻" + ((if . > 1e12 then . / 1000 else . end) | floor | strflocaltime(fmt))
    else " ↻" + (sub("\\.[0-9]+"; "") | sub("(Z|[+-]00:?00)$"; "") | strptime("%Y-%m-%dT%H:%M:%S") | mktime | strflocaltime(fmt))
    end;
  def limit(name; fmt):
    if . == null then "\(name) –"
    else (.used_percentage | num) as $u
      | "\(name) \($u | pct) used · \(if $u == null then "–" else "\(100 - ($u | round))%" end) left\(.resets_at | try reset(fmt) catch "")"
    end;

  (.context_window // {}) as $c
  | ($c.context_window_size | num) as $size
  | (if ($c.current_usage | type) == "object"
     then [$c.current_usage.input_tokens, $c.current_usage.cache_creation_input_tokens, $c.current_usage.cache_read_input_tokens] | map(num // 0) | add
     else null end) as $used0
  | ($c.used_percentage | num) as $pct0
  | ($used0 // (if $pct0 != null and $size != null then $pct0 * $size / 100 else null end)) as $used
  | ($pct0 // (if $used != null and $size != null and $size > 0 then $used * 100 / $size else null end)) as $pct
  | [ (.model.display_name // .model.id // "?"),
      "ctx \($used | k)/\($size | k) \($pct | pct)",
      (.cost.total_cost_usd // 0 | money),
      (.rate_limits.five_hour | limit("5h"; "%H:%M")),
      (.rate_limits.seven_day | limit("wk"; "%a %H:%M"))
    ] | join(" │ ")
'
