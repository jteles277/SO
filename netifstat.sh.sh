#!/bin/bash

# functions
    Regex(){
        #Runs trough all of the interfaces and checks wich ones contain the regex in question
        for (( i=0; i < $N; i++ ))
        do
            interface_name=$(echo "${data[$i]}" | awk '{print $1;}'); 
            if [[ ${interface_name} =~ ^$Regex$ ]]; then 
                new_array+=( "${data[i]}" )                  # adds the interface in a intermidiate array
            fi                                          
        done

        data=("${new_array[@]}")        # reset the array data
        unset new_array                 #unsets the array since it has no more use
        
        #reset the number of interfaces
        N=${#data[@]};

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

    #check if sleep time is an integer

    if ! [[ ${@: -1} =~ ^[0-9]+$ ]] ; then
        echo "error" 
        echo "Last argument should be integer"    #error, last argument should be integer
        exit 1                                    #error code
    fi

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
    getRegex=0;         # boolean to help manage regex
    Regex="";           
    iter=0:             #iterator to help manage the number of argumens passed
    # process options
    for op in "$@"; do
        #get penultimate argument and checks if is diferent from other cases
        i=$(($i + 1))

        if [ $getMax -eq 1 ]; then    
            if [ $i -eq $# ]; then
                echo "error" 
                echo "Argument after -p should be integer"    #error, last argument should be integer
                exit 2                                        #error code
            fi     
            if ! [[ $op =~ ^[0-9]+$ ]] ; then
                echo "error" 
                echo "Argument after -p should be integer"    #error, last argument should be integer
                exit 2                                        #error code
            fi  
            max=$op;
            getMax=0;   
            continue;
        elif [ $getRegex -eq 1 ]; then
            Regex="$op"
            getRegex=0
            continue;
        fi        
        if [ $i -eq $# ]; then

            continue;

        fi
        case $op in
            -c)
                getRegex=1;
                continue
                ;;
            -l)
                loop=1;
                continue
                ;;
            -p)
                getMax=1;
                continue
                ;;
            -b)
                byte_div=1;
                continue
                ;;
            -k)
                byte_div=1000
                continue
                ;;
            -m)
                byte_div=1000000
                continue
                ;;
            -v)
                reversed=1
                continue
                ;;
            -r)
                order="r"
                continue
                ;;
            -t)
                order="t"
                continue
                ;;  
            -R)
                order="r"
                continue
                ;;
            -T)
                order="t"
                continue
                ;;  
        esac


        #if it reaches here then the argument passed is not valid

        echo "error" 
        echo "Argument $op is invalid"    #error, invalid argument
        exit 3                                       #error code

    done

    
    
    # setting inicial value of total tx and rx 
    tot_tx=();
    tot_rx=();

    #interation
    iter=0;

    while [ $looping -eq 1 ]; do 

        # get inicial array and organize it in: i_data[] = interface_name rx tx
        IFS=$'\n' read -r -d '' -a interfaces < <( ifconfig -a | grep ": " | awk '{print $1}' | tr -d :  )
        IFS=$'\n' read -r -d '' -a RXs < <( ifconfig -a | grep "RX packets" | awk '{print $5}' )  
        IFS=$'\n' read -r -d '' -a TXs < <( ifconfig -a | grep "TX packets" | awk '{print $5}' )
        N=${#interfaces[@]};
        for ((i=0; i < $N; i++ ))
        do
            i_data[$i]="${interfaces[$i]} ${RXs[$i]} ${TXs[$i]}";  
        done    
        
        # wait given seconds
        sleep $sleep_time

        # get final array and organize it in: i_data[] = interface_name rx tx
        IFS=$'\n' read -r -d '' -a interfaces < <( ifconfig -a | grep ": " | awk '{print $1}' | tr -d :  )
        IFS=$'\n' read -r -d '' -a RXs < <( ifconfig -a | grep "RX packets" | awk '{print $5}' )  
        IFS=$'\n' read -r -d '' -a TXs < <( ifconfig -a | grep "TX packets" | awk '{print $5}' )
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
        # Reverse
        if [[ $reversed -eq 1 ]]
        then 
            Reverse
        fi
        # -p
        if [ $N -gt $max ]; then
            N=$(($max));
        fi   
        # -c
        if [ ! -z "$Regex" ]; then
            #Regex will remove the ones that dont match regex pattern
            Regex
        fi

        # print Label
        if [ $iter -eq 0 ]; then
            if [ $loop -eq 1 ]; 
            then
                printf "%-11s %9s %9s %9s %9s %9s %9s\n" "NETIF" "TX" "RX" "TRATE" "RRATE" "TXTOT" "RXTOT";  
            else
                printf "%-11s %9s %9s %9s %9s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"; 
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

                printf "%-11s %9s %9s %9s %9s %9s %9s\n" $int $tx $rx $t_rate $r_rate $tmp_tot_tx $tmp_tot_rx;
            else
                printf "%-11s %9s %9s %9s %9s\n" $int $tx $rx $t_rate $r_rate;
            fi  
            
        done
        printf "\n";

        # define if its to continue looping or not
        looping=$loop;
        iter=$(($iter+1));

    done
#