{ pkgs, ... }:
let
  autotile = pkgs.writeShellApplication {
    name = "tmux-autotile";
    runtimeInputs = [ pkgs.gawk ];
    text = ''
      active=80   # percent the focused branch takes at every split it passes through

      # Rewrite the whole layout so the focused pane's branch gets `active`% at
      # every split between the root and that pane ("cascade"). resize-pane can
      # only move the one boundary touching the focused pane, so instead we
      # recompute the entire tree and apply it atomically with select-layout.
      # See the awk below for the layout grammar and the algorithm.
      cascade() {
        awk -v layout="$1" -v focusX="$2" -v focusY="$3" -v active="$4" '
          # -------------------------------------------------------------------
          # Reads tmux window_layout and rewrites it so the focused pane gets
          # active% at EVERY split between the root and that pane. Prints
          # "<checksum>,<body>" ready for select-layout.
          #
          # Grammar (after the leading checksum is stripped by the shell):
          #   node = "<width>x<height>,<x>,<y>" then one of:
          #            ",<paneIndex>"          a leaf (a real pane)
          #            "{" node,node,... "}"   left/right split (divides WIDTH)
          #            "[" node,node,... "]"   top/bottom split (divides HEIGHT)
          #   A divider costs one cell: sum(child sizes) + (k-1) = parent size.
          # -------------------------------------------------------------------
          BEGIN {
            cursor = 1                          # read position within layout
            layoutLen = length(layout)
            nodeCount = 0
            focusedNode = 0

            # awk has no ord(): build a char -> byte table once, for the checksum
            for (code = 0; code < 256; code++)
              ASCII[sprintf("%c", code)] = code

            rootNode = parseNode(0)
            if (focusedNode == 0)
              exit 0                            # focused corner not found: leave layout alone

            # mark every node from the focused leaf up to the root
            for (node = focusedNode; node != 0; node = parentOf[node])
              onPath[node] = 1

            resize(rootNode, width[rootNode], height[rootNode])

            body = serialize(rootNode)
            printf "%04x,%s\n", checksum(body), body
          }

          # read a run of digits at the cursor, return it as a number
          function readInt(    start, ch) {
            start = cursor
            while (cursor <= layoutLen) {
              ch = substr(layout, cursor, 1)
              if (ch >= "0" && ch <= "9") cursor++
              else break
            }
            return substr(layout, start, cursor - start) + 0
          }

          # if the next char is token, consume it and return 1; else return 0
          function consume(token) {
            if (substr(layout, cursor, 1) == token) { cursor++; return 1 }
            return 0
          }

          # recursive-descent parse; creates one node, returns its id
          function parseNode(parentId,    node, nextChar, childIndex) {
            node = ++nodeCount
            parentOf[node] = parentId

            width[node]  = readInt(); consume("x")
            height[node] = readInt(); consume(",")
            posX[node]   = readInt(); consume(",")
            posY[node]   = readInt()

            nextChar = substr(layout, cursor, 1)
            if (nextChar == "{" || nextChar == "[") {
              bracket[node] = nextChar              # "{" divides width, "[" divides height
              cursor++                              # step over the opening bracket
              childIndex = 0
              child[node, childIndex++] = parseNode(node)
              while (consume(","))
                child[node, childIndex++] = parseNode(node)
              consume(nextChar == "{" ? "}" : "]")  # step over the closing bracket
              childCount[node] = childIndex
            } else {
              bracket[node] = ""                    # leaf: ",<paneIndex>"
              childCount[node] = 0
              consume(",")
              paneIndex[node] = readInt()
              if (posX[node] == focusX && posY[node] == focusY) focusedNode = node
            }
            return node
          }

          # Divide available cells among a node s children, writing into share[].
          # alongWidth is 1 when the split divides width, else 0. focusedChild is
          # the on-path child index, or -1 if this split is not on the path.
          function splitSizes(node, available, alongWidth, focusedChild,
                              count, i, kid, total, focusedShare, maxShare,
                              remaining, othersTotal, assigned, lastOther, size, leftover, deficit) {
            count = childCount[node]

            # current size of each child along the split axis (keeps proportions)
            total = 0
            for (i = 0; i < count; i++) {
              kid = child[node, i]
              current[i] = alongWidth ? width[kid] : height[kid]
              total += current[i]
            }

            if (focusedChild >= 0) {
              # the on-path child gets active%; the others share what remains
              focusedShare = int(active * available / 100 + 0.5)
              maxShare = available - (count - 1)        # leave >= 1 cell per other child
              if (focusedShare > maxShare) focusedShare = maxShare
              if (focusedShare < 1)        focusedShare = 1
              share[focusedChild] = focusedShare

              remaining = available - focusedShare
              othersTotal = total - current[focusedChild]
              assigned = 0
              lastOther = -1
              for (i = 0; i < count; i++) {
                if (i == focusedChild) continue
                size = (othersTotal > 0) ? int(remaining * current[i] / othersTotal) : int(remaining / (count - 1))
                if (size < 1) size = 1
                share[i] = size
                assigned += size
                lastOther = i
              }
              # rounding rarely sums exactly: push the difference onto the last other
              leftover = remaining - assigned
              share[lastOther] += leftover
              if (share[lastOther] < 1) {
                deficit = 1 - share[lastOther]
                share[lastOther] = 1
                share[focusedChild] -= deficit
              }
            } else {
              # not on the path: scale children to fit, keeping their proportions
              assigned = 0
              lastOther = -1
              for (i = 0; i < count; i++) {
                size = (total > 0) ? int(available * current[i] / total) : int(available / count)
                if (size < 1) size = 1
                share[i] = size
                assigned += size
                lastOther = i
              }
              leftover = available - assigned
              share[lastOther] += leftover
              if (share[lastOther] < 1) share[lastOther] = 1
            }
          }

          # Set a node to (newWidth, newHeight) and lay its children out to match.
          # childSize[] is an extra parameter so it is LOCAL to this call -- the
          # recursion would otherwise clobber it through the global share[].
          function resize(node, newWidth, newHeight,
                          count, i, kid, focusedChild, available, childSize, offset) {
            width[node]  = newWidth
            height[node] = newHeight
            if (bracket[node] == "") return         # leaf: nothing to subdivide

            count = childCount[node]

            # which child (if any) lies on the focused path?
            focusedChild = -1
            if (onPath[node])
              for (i = 0; i < count; i++)
                if (onPath[child[node, i]]) focusedChild = i

            if (bracket[node] == "{") {
              # left/right split: divide width; children keep the full height
              available = newWidth - (count - 1)
              splitSizes(node, available, 1, focusedChild)
              for (i = 0; i < count; i++) childSize[i] = share[i]   # snapshot before recursing
              offset = posX[node]
              for (i = 0; i < count; i++) {
                kid = child[node, i]
                posX[kid] = offset
                posY[kid] = posY[node]
                resize(kid, childSize[i], newHeight)
                offset += childSize[i] + 1                          # +1 for the divider cell
              }
            } else {
              # top/bottom split: divide height; children keep the full width
              available = newHeight - (count - 1)
              splitSizes(node, available, 0, focusedChild)
              for (i = 0; i < count; i++) childSize[i] = share[i]
              offset = posY[node]
              for (i = 0; i < count; i++) {
                kid = child[node, i]
                posY[kid] = offset
                posX[kid] = posX[node]
                resize(kid, newWidth, childSize[i])
                offset += childSize[i] + 1
              }
            }
          }

          # turn the (resized) tree back into a layout string
          function serialize(node,    text, i) {
            text = width[node] "x" height[node] "," posX[node] "," posY[node]
            if (bracket[node] == "") return text "," paneIndex[node]
            text = text bracket[node]
            for (i = 0; i < childCount[node]; i++)
              text = text (i ? "," : "") serialize(child[node, i])
            return text (bracket[node] == "{" ? "}" : "]")
          }

          # tmux checksum: rotate the 16-bit sum right one bit, then add each
          # byte. awk has no >> or &, so int(/2)+carry and %65536 stand in.
          function checksum(text,    sum, i, byte) {
            sum = 0
            for (i = 1; i <= length(text); i++) {
              sum = int(sum / 2) + ((sum % 2) * 32768)    # rotate low bit up to bit 15
              byte = ASCII[substr(text, i, 1)]            # ord() via the BEGIN table
              sum = (sum + byte) % 65536
            }
            return sum
          }
        '
      }

      apply() {
        [ "$(tmux show -gv @autotile 2>/dev/null)" = "on" ] || return 0

        # window_layout has no spaces, so it splits off cleanly before the coords
        read -r layout px py <<<"$(tmux display-message -p \
          '#{window_layout} #{pane_left} #{pane_top}')"

        new=$(cascade "''${layout#*,}" "$px" "$py" "$active")   # strip checksum, rebuild
        if [ -n "$new" ]; then tmux select-layout "$new" 2>/dev/null || true; fi
      }

      case "''${1:-apply}" in
        toggle)
          if [ "$(tmux show -gv @autotile 2>/dev/null)" = "on" ]; then
            tmux set -g @autotile off
            tmux display-message "auto-tile: OFF (sizes frozen)"
          else
            tmux set -g @autotile on
            tmux display-message "auto-tile: ON"
            apply   # take effect immediately on the currently focused pane
          fi
          ;;
        *) apply ;;
      esac
    '';
  };
in
{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    baseIndex = 1;
    historyLimit = 50000;
    terminal = "tmux-256color";
    mouse = true;
    focusEvents = true;
    prefix = "S-F3";
    escapeTime = 10;
    customPaneNavigationAndResize = true;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour mocha
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_window_text " #{b:pane_current_path} #{pane_current_command}"
          set -g @catppuccin_window_default_text " #{b:pane_current_path} #{pane_current_command}"
          set -g @catppuccin_window_current_text " #{b:pane_current_path} #{pane_current_command}"

          # Must be set before prefix-highlight runs (it does string replacement, not a tmux format)
          set -g status-left " #{prefix_highlight}"
          set -g status-left-length 100
          set -g status-right "session: #{session_name} #{E:@catppuccin_status_application} "
          set -g status-right-length 100
        '';
      }
      prefix-highlight
    ];

    extraConfig = ''
      bind-key S-F3 send-prefix
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded"
      bind % split-window -h -c '#{pane_current_path}'
      bind '"' split-window -v -c '#{pane_current_path}'

      set -g @autotile off
      set-hook -g pane-focus-in 'run-shell -b "${autotile}/bin/tmux-autotile apply"'
      bind a run-shell "${autotile}/bin/tmux-autotile toggle"
    '';
  };
}
