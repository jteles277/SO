#!/bin/bash

 
# get inicial array 
IFS=$'\n' read -r -d '' -a i_data < <( ifconfig -a -s | awk 'BEGIN{OFS ="\t"}; {print $1, $3, $7;}' ) # interfaces

 
sleep $1

# get final array
IFS=$'\n' read -r -d '' -a data < <( ifconfig -a -s | awk 'BEGIN{OFS ="\t"}; {print $1, $3, $7;}' ) # interfaces

 

N=${#data[@]};  
for((i=1;i<N;i++))
do
  x=$(echo "${data[$i]}" | awk '{print $2;}');
  echo $x;
done



#damn that ass boyyyyyyyyy

