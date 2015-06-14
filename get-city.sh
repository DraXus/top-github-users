#!/usr/bin/env bash

if [[ $# -eq 0 ]] ; then
    echo "Better use ./get-city-sh <city name>"
fi
coffee get-users.coffee $@
#coffee check-logins.coffee $@
coffee get-details.coffee $@
coffee format-languages.coffee $@
coffee format-users.coffee $@
