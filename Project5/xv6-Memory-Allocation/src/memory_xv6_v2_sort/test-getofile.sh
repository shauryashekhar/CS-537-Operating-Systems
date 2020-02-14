#! /bin/bash

if ! [[ -d v2-sort ]]; then
    echo "The v2-sort dir does not exist."
    echo "Your xv6 code should be in the v2-sort directory"
    echo "to enable the automatic tester to work."
    exit 1
fi

../tester/run-tests.sh $*
