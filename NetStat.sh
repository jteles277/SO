#!/bin/bash

# functions
  SortRx() {
    # basic selection sort  
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


    # get inicial array and organize it in: i_data[] = interface rx tx
    IFS=$'\n' read -r -d '' -a interfaces < <( ifconfig -a | grep ": " | awk '{print $1}' | tr -d : && printf '\0' )
    IFS=$'\n' read -r -d '' -a i_RXs < <( ifconfig -a | grep "RX packets" | awk '{print $5}' | tr -d : && printf '\0' )  
    IFS=$'\n' read -r -d '' -a f_TXs < <( ifconfig -a | grep "TX packets" | awk '{print $5}' | tr -d : && printf '\0' )
    N=${#interfaces[@]};
    for ((i=1; i < $N; i++ ))
    do
        i_data[$i]="${interfaces[$i]} ${i_RXs[$i]} ${f_TXs[$i]}";
    done    
    
    # wait given seconds
    sleep $1

    # get final array and organize it in: i_data[] = interface rx tx
    IFS=$'\n' read -r -d '' -a interfaces < <( ifconfig -a | grep ": " | awk '{print $1}' | tr -d : && printf '\0' )
    IFS=$'\n' read -r -d '' -a i_RXs < <( ifconfig -a | grep "RX packets" | awk '{print $5}' | tr -d : && printf '\0' )  
    IFS=$'\n' read -r -d '' -a f_TXs < <( ifconfig -a | grep "TX packets" | awk '{print $5}' | tr -d : && printf '\0' )
    for ((i=1; i < $N; i++ ))
    do
        data[$i]="${interfaces[$i]} ${i_RXs[$i]} ${f_TXs[$i]}";
    done    
    



    #get
    for ((i=1; i < $N; i++ ))
    do  
        # get innterface
        interface=$(echo "${i_data[$i]}" | awk '{print $1;}');

        # rx/tx = get rx/tx from array  |  dif = rFinal - rInicial  |  rate  = dif/#secs

        # r
        i_rx=$(echo "${i_data[$i]}" | awk '{print $2;}');
        rx=$(echo "${data[$i]}" | awk '{print $2;}');
        r_Dif=($(($rx-$i_rx))); 
        r_Rate=($(($r_Dif/$1)));

        # t
        i_tx=$(echo "${i_data[$i]}" | awk '{print $3;}');
        tx=$(echo "${data[$i]}" | awk '{print $3;}');
        t_Dif=($(($tx-$i_tx))); 
        t_Rate=($(($t_Dif/$1)));

        # return changed and added values to the array  
        data[$i]="$interface $t_Dif $r_Dif $t_Rate $r_Rate";
        
    done

    # Base Sort
    SortRx

    #print 
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