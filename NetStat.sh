#!/bin/bash

# functions
  SortRx() {
    for (( i = 1; $i < $(($N-1)); $((i = $i + 1)) ))
    do
	    for (( e = $(($i+1)); $e < $N; $((e = $e + 1)) ))
	    do

        rx_i=$(echo "${data[$i]}" | awk '{print $3;}');
        rx_e=$(echo "${data[$e]}" | awk '{print $3;}'); 

		    if [[ $rx_e -gt $rx_i ]]
        then 

          
          temp=${data[$e]};
          data[$e]=${data[$i]};
          data[$i]=$temp;

             
		    fi
	    done
    done
  }
#

# main


  # get inicial array 
  IFS=$'\n' read -r -d '' -a i_data < <( ifconfig -a -s | awk 'BEGIN{OFS ="\t"}; {print $1, $3, $7;}' )  
  N=${#i_data[@]}; 
  
  sleep $1

  # get final array
  IFS=$'\n' read -r -d '' -a data < <( ifconfig -a -s | awk 'BEGIN{OFS ="\t"}; {print $1, $3, $7;}' )  




  for ((i=1; i < $N; i++ ))
  do
    interface=$(echo "${i_data[$i]}" | awk '{print $1;}');

    i_rx=$(echo "${i_data[$i]}" | awk '{print $2;}');
    rx=$(echo "${data[$i]}" | awk '{print $2;}');
    r_Dif=($(($rx-$i_rx))); # r
    r_Rate=($(($r_Dif/$1)));

    i_tx=$(echo "${i_data[$i]}" | awk '{print $3;}');
    tx=$(echo "${data[$i]}" | awk '{print $3;}');
    t_Dif=($(($tx-$i_tx))); # r
    t_Rate=($(($t_Dif/$1)));

    data[$i]="$interface $t_Dif $r_Dif $t_Rate $r_Rate";
    
  done

  SortRx

  printf "%9s %9s %9s %9s %9s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"; # print
  for (( i=1; i < $N; i++ )); do
    int=$(echo "${data[$i]}" | awk '{print $1;}');
    tx=$(echo "${data[$i]}" | awk '{print $2;}');
    rx=$(echo "${data[$i]}" | awk '{print $3;}');
    t_rate=$(echo "${data[$i]}" | awk '{print $4;}');
    r_rate=$(echo "${data[$i]}" | awk '{print $5;}');


    printf "%9s %9s %9s %9s %9s\n" $int $tx $rx $t_rate $r_rate;
  done

#