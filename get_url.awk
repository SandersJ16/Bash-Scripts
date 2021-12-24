#!/usr/bin/awk

BEGIN {
    submodule_matches = 0;
    if (length(submodule_name) == 0) {
        print "Must supply variablie `submodule_name`. This can be done using the -v flag"
        exit 1
    }
}

$0 ~ "^\[submodule \""submodule_name"\"\]$" {
    submodule_matches = 1
}

submodule_matches && /url = / {
    print $3
    exit
}

