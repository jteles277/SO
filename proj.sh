#!/bin/bash

# functions

    Reverse(){

         
        for (( i = 0; $i <= $(($N - $i - 1)); $((i = $i + 1)) ))
        do
	        f=$(($N - $i - 1));
            #interfaces
            temp=${interfaces[$f]};
            interfaces[$f]=${interfaces[$i]};
            interfaces[$i]=$temp;

            #rx
            temp=${f_RXs[$f]};
            f_RXs[$f]=${f_RXs[$i]};
            f_RXs[$i]=$temp;
                
            #tx
            temp=${f_TXs[$f]};
            f_TXs[$f]=${f_TXs[$i]};
            f_TXs[$i]=$temp;

            #rRate
            temp=${r_Rate[$f]};
            r_Rate[$f]=${r_Rate[$i]};
            r_Rate[$i]=$temp;

            #tRate
            temp=${t_Rate[$f]};
            t_Rate[$f]=${t_Rate[$i]};
            t_Rate[$i]=$temp;
		    
        done
    }

    SortRx() {

        for (( i = 0; $i < $(($N-1)); $((i = $i + 1)) ))
        do
	        for (( e = $(($i+1)); $e < $N; $((e = $e + 1)) ))
	        do
		
		        if [[ ${f_RXs[$e]} -gt ${f_RXs[$i]} ]]
                then 
                
                    #interfaces
                    temp=${interfaces[$e]};
                    interfaces[$e]=${interfaces[$i]};
                    interfaces[$i]=$temp;

                    #rx
                    temp=${f_RXs[$e]};
                    f_RXs[$e]=${f_RXs[$i]};
                    f_RXs[$i]=$temp;
                
                    #tx
                    temp=${f_TXs[$e]};
                    f_TXs[$e]=${f_TXs[$i]};
                    f_TXs[$i]=$temp;

                    #rRate
                    temp=${r_Rate[$e]};
                    r_Rate[$e]=${r_Rate[$i]};
                    r_Rate[$i]=$temp;

                    #tRate
                    temp=${t_Rate[$e]};
                    t_Rate[$e]=${t_Rate[$i]};
                    t_Rate[$i]=$temp;
		        fi
	        done
        done
    }
    
#

# main

    if [[ $1 != ?(-)+([0-9]) ]]; then
        echo "number of seconds necessary"
        exit
    fi

    # set up arrays
    IFS=$'\n' read -r -d '' -a interfaces < <( ifconfig -a | grep ": " | awk '{print $1}' | tr -d : && printf '\0' ) # interfaces
    N=${#interfaces[@]};  

    IFS=$'\n' read -r -d '' -a i_RXs < <( ifconfig -a | grep "RX packets" | awk '{print $5}' | tr -d : && printf '\0' ) # inicial rx and tx 
    IFS=$'\n' read -r -d '' -a f_TXs < <( ifconfig -a | grep "TX packets" | awk '{print $5}' | tr -d : && printf '\0' )

    sleep $1; # wait given seconds

    IFS=$'\n' read -r -d '' -a f_RXs < <( ifconfig -a | grep "RX packets" | awk '{print $5}' | tr -d : && printf '\0' ) # final rx and tx 
    IFS=$'\n' read -r -d '' -a f_TXs < <( ifconfig -a | grep "TX packets" | awk '{print $5}' | tr -d : && printf '\0' )

    r_Rate=();# set up rate arrays
    t_Rate=();

    for (( i=0; i < $N; i++ )); do

        # dif = rFinal - rInicial  |  rate  = dif/#secs
        RDif=($((f_RXs[$i]-i_RXs[$i]))); # r
        f_RXs[$i]=$RDif;
        r_Rate+=($((RDif/$1)));
        TDif=($((f_TXs[$i]-f_TXs[$i]))); # t
        f_TXs[$i]=$TDif;
        t_Rate+=($((TDif/$1)));
    done

    SortRx

    printf "%10s %10s %10s %10s %10s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"; # print
    for (( i=0; i < $N; i++ )); do
        printf "%10s %10s %10s %10s %10s\n" ${interfaces[$i]} ${f_TXs[$i]} ${f_RXs[$i]} ${t_Rate[$i]} ${r_Rate[$i]};
    done

#