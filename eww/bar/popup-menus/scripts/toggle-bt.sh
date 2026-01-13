#!/bin/bash

if [[ -z $(eww active-windows | grep 'toggle-menu-bt') ]]; then
    eww open toggle-menu-bt && eww update tgbrev=true
else
    eww update tgbrev=false
    (sleep 0.2 && eww close toggle-menu-bt) &
fi
