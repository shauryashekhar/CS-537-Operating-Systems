#! /bin/bash

set -x
set -e

start=26
end=30

j=0


for i in $(seq $start $end); do
	(( j = i - 5 ))
	mv tests/$i.desc tests/$j.out
	mv tests/$i.run tests/$j.run
	#cp -f tests/$j.out tests/$i.out
	#cp -f tests/$j.err tests/$i.err
	#cp -f tests/$j.desc tests/$i.desc
	#cp -f tests/$j.run tests/$i.run
done
