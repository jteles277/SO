#!/bin/bash

# functions
    Regex(){
        #Runs trough all of the interfaces and checks wich ones dont contain the regex in question
        for (( i=1; i < $N; i++ ))
        do
            interface_name=$(echo "${data[$i]}" | awk '{print $1;}'); 
            echo $regex
            if [[ ${interface_name} =~ ^$regex$ ]]; then # bruno disse que isto funcionava mas so funciona quando o 
                echo $interface_name                     # regex e exatamente igual   
            fi                                           #precisa de uma nova solução 

        done
    }
    Reverse(){
        # reverse order
        for (( i = 0; $i <= $(($N - $i - 1)); $((i = $i + 1)) ))
        do
	        f=$(($N - $i - 1));
            
            temp=${data[$f]};
            data[$f]=${data[$i]};
            data[$i]=$temp;
		    
        done
    }
    SortRx() {
        # basic selection sort  
        for (( i = 0; $i < $(($N-1)); $((i = $i + 1)) ))
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
        for (( i = 0; $i < $(($N-1)); $((i = $i + 1)) ))
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
    byte_div=1;         # variable that will help show desirable size
    reversed=0;         # boolean to know if is to reverse
    order="alpha";      # type of sort to be used
    max=10;             # max number of interfaces to be shown
    getMax=0;           # boolean to help manage last one
    loop=0;             # boolean to declare if is to loop or not
    looping=1;          # boolean to show the state(if is looping or not)
    regex=""
    # process options
    for op in "$@"; do
        #get penultimate argument and checks if is diferent from other cases
      if [[ "$op" == "${@:(-2):1}" ]] && [[ "$op" != "-"* ]] && [ $getMax -ne 1 ]; then
           regex="$op"
      fi
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

    
    
    # setting inicial value of total tx and rx 
    tot_tx=();
    tot_rx=();

    #interation
    iter=0;

    while [ $looping -eq 1 ]; do 

        # get inicial array and organize it in: i_data[] = interface_name rx tx
        IFS=$'\n' read -r -d '' -a interfaces < <( ifconfig -a | grep ": " | awk '{print $1}' | tr -d : && printf '\0' )
        IFS=$'\n' read -r -d '' -a RXs < <( ifconfig -a | grep "RX packets" | awk '{print $5}' | tr -d : && printf '\0' )  
        IFS=$'\n' read -r -d '' -a TXs < <( ifconfig -a | grep "TX packets" | awk '{print $5}' | tr -d : && printf '\0' )
        N=${#interfaces[@]};
        for ((i=0; i < $N; i++ ))
        do
            i_data[$i]="${interfaces[$i]} ${RXs[$i]} ${TXs[$i]}";  
        done    
        
        # wait given seconds
        sleep $sleep_time

        # get final array and organize it in: i_data[] = interface_name rx tx
        IFS=$'\n' read -r -d '' -a interfaces < <( ifconfig -a | grep ": " | awk '{print $1}' | tr -d : && printf '\0' )
        IFS=$'\n' read -r -d '' -a RXs < <( ifconfig -a | grep "RX packets" | awk '{print $5}' | tr -d : && printf '\0' )  
        IFS=$'\n' read -r -d '' -a TXs < <( ifconfig -a | grep "TX packets" | awk '{print $5}' | tr -d : && printf '\0' )
        for ((i=0; i < $N; i++ ))
        do
            data[$i]="${interfaces[$i]} ${RXs[$i]} ${TXs[$i]}"; 
            
        done    
        
         


        # get wanted data
        for ((i=0; i < $N; i++ ))
        do   
        
            
            # get innterface
            interface=$(echo "${i_data[$i]}" | awk '{print $1;}');

            # rx/tx = get rx/tx from array  |  Gap = rFinal - rInicial 

            # r
            i_rx=$(echo "${i_data[$i]}" | awk '{print $2;}');
            rx=$(echo "${data[$i]}" | awk '{print $2;}');
            r_Gap=($(($rx-$i_rx))); 

            # t
            i_tx=$(echo "${i_data[$i]}" | awk '{print $3;}');
            tx=$(echo "${data[$i]}" | awk '{print $3;}');
            t_Gap=($(($tx-$i_tx)));  

            # depending if is looping we have more information
            if [ $loop -eq 1 ]; 
            then    

                if [ $iter -eq 0 ]; 
                then
                    tot_tx[$i]=$t_Gap;
                    tot_rx[$i]=$r_Gap;
                    
                else
                     
                    tot_tx[$i]=$((tot_tx[$i]+$t_Gap)); 
                    tot_rx[$i]=$((tot_rx[$i]+$r_Gap));
                fi
                # return changed and added values to the array  
                data[$i]="$interface $t_Gap $r_Gap ${tot_tx[$i]} ${tot_rx[$i]}"; 
                
            else
                # return changed and added values to the array  
                data[$i]="$interface $t_Gap $r_Gap ";
            fi  

           
            
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

        if [ ! -z "$regex" ]; then
            #Regex will remove the ones that dont match regex pattern
            Regex
        fi

        # print Label
        if [ $iter -eq 0 ]; then
            if [ $loop -eq 1 ]; 
            then
                printf "%-6s %9s %9s %9s %9s %9s %9s\n" "NETIF" "TX" "RX" "TRATE" "RRATE" "TXTOT" "RXTOT";  
            else
                printf "%-6s %9s %9s %9s %9s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"; 
            fi  
            
        fi  
        




        # print Information
        for (( i=0; i < $N; i++ )); do
            int=$(echo "${data[$i]}" | awk '{print $1;}'); 

            tx=$(echo "${data[$i]}" | awk '{print $2;}');
            t_rate=$(bc <<<"scale=1;($tx/$sleep_time)/$byte_div");
            tx=$((tx/byte_div));

            rx=$(echo "${data[$i]}" | awk '{print $3;}');
            r_rate=$(bc <<<"scale=1;($rx/$sleep_time)/$byte_div");
            rx=$((rx/byte_div));
            

            if [ $loop -eq 1 ]; 
            then
                tmp_tot_tx=$(echo "${data[$i]}" | awk '{print $4;}');
                tmp_tot_tx=$((tmp_tot_tx/byte_div));
                tmp_tot_rx=$(echo "${data[$i]}" | awk '{print $5;}');
                tmp_tot_rx=$((tmp_tot_rx/byte_div));

                printf "%-6s %9s %9s %9s %9s %9s %9s\n" $int $tx $rx $t_rate $r_rate $tmp_tot_tx $tmp_tot_rx;
            else
                printf "%-6s %9s %9s %9s %9s\n" $int $tx $rx $t_rate $r_rate;
            fi  
            
        done
        printf "\n";

        # define if its to continue looping or not
        looping=$loop;
        iter=$(($iter+1));

    done
#