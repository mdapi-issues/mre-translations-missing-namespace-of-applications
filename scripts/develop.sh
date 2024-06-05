#!/usr/bin/env bash

set -eo pipefail
set -x

sf org create scratch -f config/project-scratch-def.json --alias mre-translations-missing-namespace-of-applications --set-default
sf package install --package 04t6F000004DJCEQA4 --no-prompt --wait 30
sf project deploy start --source-dir fixtures/some-unrelated-translation-of-a-managed-customlabel
