#!/bin/bash

# functions
    Reverse(){
        # reverse order
        for (( i = 1; $i <= $(($N - $i)); $((i = $i + 1)) ))
        do
	        f=$(($N - $i));
            
            temp=${data[$f]};
            data[$f]=${data[$i]};
            data[$i]=$temp;
		    
        done
    }
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
  SortTx() {
    # basic selection sort  
    for (( i = 1; $i < $(($N-1)); $((i = $i + 1)) ))
    do
	    for (( e = $(($i+1)); $e < $N; $((e = $e + 1)) ))
	    do

            tx_i=$(echo "${data[$i]}" | awk '{print $2;}');
            tx_e=$(echo "${data[$e]}" | awk '{print $2;}'); 

            if [[ $tx_e -gt $tx_i ]]
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

    # get sleep time
    sleep_time=${!#};

    # set default variables
    byte_div=1;
    reversed=0;
    order="alpha";
    max=10;
    getMax=0;
    loop=0;
    looping=1;

    # process options
    for op in "$@"; do

        if [ $getMax -eq 1 ]; then
            max=$op;
            getMax=0;   
            continue;
        fi 

        case $op in
            -l)
                loop=1;
                ;;
            -p)
                getMax=1;
                ;;
            -k)
                byte_div=1000
                ;;
            -m)
                byte_div=1000000
                ;;
            -v)
                reversed=1
                ;;
            -r)
                order="r"
                ;;
            -t)
                order="t"
                ;;  
            -R)
                order="r"
                ;;
            -T)
                order="t"
                ;;        
        esac
    done

    #echo "info = $info";
    
    #interation
    iter=0;

    while [ $looping -eq 1 ]; do 

        # get inicial array and organize it in: i_data[] = interface_name rx tx
        IFS=$'\n' read -r -d '' -a interfaces < <( ifconfig -a | grep ": " | awk '{print $1}' | tr -d : && printf '\0' )
        IFS=$'\n' read -r -d '' -a i_RXs < <( ifconfig -a | grep "RX packets" | awk '{print $5}' | tr -d : && printf '\0' )  
        IFS=$'\n' read -r -d '' -a f_TXs < <( ifconfig -a | grep "TX packets" | awk '{print $5}' | tr -d : && printf '\0' )
        N=${#interfaces[@]};
        for ((i=1; i < $N; i++ ))
        do
            i_data[$i]="${interfaces[$i]} ${i_RXs[$i]} ${f_TXs[$i]}";
            echo ${i_data[$i]};
        done    
        
        # wait given seconds
        sleep $sleep_time

        # get final array and organize it in: i_data[] = interface_name rx tx
        IFS=$'\n' read -r -d '' -a interfaces < <( ifconfig -a | grep ": " | awk '{print $1}' | tr -d : && printf '\0' )
        IFS=$'\n' read -r -d '' -a i_RXs < <( ifconfig -a | grep "RX packets" | awk '{print $5}' | tr -d : && printf '\0' )  
        IFS=$'\n' read -r -d '' -a f_TXs < <( ifconfig -a | grep "TX packets" | awk '{print $5}' | tr -d : && printf '\0' )
        for ((i=1; i < $N; i++ ))
        do
            data[$i]="${interfaces[$i]} ${i_RXs[$i]} ${f_TXs[$i]}";
            echo ${data[$i]};
        done    
        



        # get wanted data
        for ((i=1; i < $N; i++ ))
        do  
            # get innterface
            interface=$(echo "${i_data[$i]}" | awk '{print $1;}');

            # rx/tx = get rx/tx from array  |  Gap = rFinal - rInicial  |  rate  = Gap/#secs

            # r
            i_rx=$(echo "${i_data[$i]}" | awk '{print $2;}');
            rx=$(echo "${data[$i]}" | awk '{print $2;}');
            r_Gap=($(($rx-$i_rx)));
            r_Gap=$((r_Gap/byte_div));
            r_Rate=$(bc <<<"scale=1;$r_Gap/$sleep_time");

            # t
            i_tx=$(echo "${i_data[$i]}" | awk '{print $3;}');
            tx=$(echo "${data[$i]}" | awk '{print $3;}');
            t_Gap=($(($tx-$i_tx))); 
            t_Gap=$((t_Gap/byte_div));
            t_Rate=$(bc <<<"scale=1;$t_Gap/$sleep_time");

            # return changed and added values to the array  
            data[$i]="$interface $t_Gap $r_Gap $t_Rate $r_Rate";
            
        done
    
        # Sort
        case $order in
            r)
                SortRx
                ;;
            t)
                SortTx
                ;;
        esac
        if [[ $reversed -eq 1 ]]
        then 
            Reverse
        fi

        if [ $N -gt $max ]; then
            N=$(($max+1));
        fi   

        #print 
        if [ $iter -eq 0 ]; then
            printf "%9s %9s %9s %9s %9s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"; # print
        fi  
        
        for (( i=1; i < $N; i++ )); do
            int=$(echo "${data[$i]}" | awk '{print $1;}');
            tx=$(echo "${data[$i]}" | awk '{print $2;}');
            rx=$(echo "${data[$i]}" | awk '{print $3;}');
            t_rate=$(echo "${data[$i]}" | awk '{print $4;}');
            r_rate=$(echo "${data[$i]}" | awk '{print $5;}');

            printf "%9s %9s %9s %9s %9s\n" $int $tx $rx $t_rate $r_rate;
        done

        # define if its to continue looping or not
        looping=$loop;
        iter=$(($iter+1));
    done
#