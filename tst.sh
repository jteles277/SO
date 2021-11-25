#!/bin/bash
 
IFS=$'\n' read -r -d '' -a interfaces < <( ifconfig -a | grep ": " | awk '{print $1}' | tr -d : && printf '\0' )
IFS=$'\n' read -r -d '' -a i_RXs < <( ifconfig -a | grep "RX packets" | awk '{print $5}' | tr -d : && printf '\0' )  
IFS=$'\n' read -r -d '' -a f_TXs < <( ifconfig -a | grep "TX packets" | awk '{print $5}' | tr -d : && printf '\0' )
N=${#interfaces[@]};
for ((i=1; i < $N; i++ ))
do
    i_data[$i]="${interfaces[$i]} ${i_RXs[$i]} ${f_TXs[$i]}";
    echo ${i_data[$i]};
done   



