#! /bin/bash

if ! [[ -d v1b ]]; then
    echo "The v1b dir does not exist."
    echo "Your xv6 code should be in the v1b directory"
    echo "to enable the automatic tester to work."
    exit 1
fi

../tester/run-tests.sh $*
