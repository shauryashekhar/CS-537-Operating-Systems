#! /bin/bash

set -x
set -e

start=1
end=40


for i in $(seq $start $end); do
        rm -f tests/$i.desc
	cp -f ~cs537-1/handin/dyf/p4/xv6-scheduler/tests-out/$i.out tests/$i.out
 	cp -f ~cs537-1/handin/dyf/p4/xv6-scheduler/tests-out/$i.rc tests/$i.rc
	cp -f ~cs537-1/handin/dyf/p4/xv6-scheduler/tests-out/$i.err tests/$i.err
done
