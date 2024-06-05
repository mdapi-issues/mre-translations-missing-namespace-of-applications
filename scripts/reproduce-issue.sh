#!/usr/bin/env bash

set -eo pipefail
set -x

sf project retrieve start -m Translations
if grep -r -B3 -A1 "<name>Address_Picker_Autocomplete</name>" force-app/main/default/translations; then
    echo "--> issue reproduced: the translations don't contain the namespace prefix"
else
    echo "--> issue could not be reprodued"
    exit 1
fi
