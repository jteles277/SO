#!/bin/bash

country="$1"
modified=${country::-1}
var2="${modified}*"
var3="*${country:1}"
var4="*${modified:1}*"
if  [ "$country" = "$var2" ] && [ "$country" != "$var4" ]; then
    echo $modified # "port"
    echo mod1
elif  [ "$country" = "$var3" ] && [ "$country" != "$var4" ]; then
    echo $country
    echo mod2
elif  [ "$country" = "$var4" ]; then
    echo $country
    echo mod3
fi


divisao + 0.5 e dps round

fazer a conta em bytes sempre 
so dar round no print