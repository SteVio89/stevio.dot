#!/bin/sh
set -e

sbx settings set ssh.agentForwardingEnabled false
sbx settings set skills.defaultMode off          # no shared skills store
sbx settings set diagnostics.autoUpload no
sbx policy deny network "*.googleapis.com"
sbx daemon restart
sbx settings list --no-trunc
sbx policy ls
