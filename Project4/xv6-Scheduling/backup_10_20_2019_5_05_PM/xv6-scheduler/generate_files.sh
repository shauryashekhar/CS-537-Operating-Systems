#! /bin/bash

set -x
set -e

start=1
end=40


for i in $(seq $start $end); do
        rm -f tests/$i.err tests/$i.rc tests/$i.run tests/$i.out tests/$i.desc
    touch tests/$i.err
    echo "0" > tests/$i.rc
    echo "cd src; ../../tester/run-xv6-command.exp CPUS=1 Makefile.test test_$i | grep "XV6_SCHEDULER"; cd .." > tests/$i.run
    touch tests/$i.out
    touch tests/$i.desc
done
