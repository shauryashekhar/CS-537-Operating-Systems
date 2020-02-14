#! /bin/bash

if ! [[ -d v1a ]]; then
    echo "The v1a dir does not exist."
    echo "Your xv6 code should be in the v1a directory"
    echo "to enable the automatic tester to work."
    exit 1
fi

../tester/run-tests.sh $*
