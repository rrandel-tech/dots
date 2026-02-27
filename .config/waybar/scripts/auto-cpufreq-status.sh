#!/bin/sh

governor=$(cpufreqctl.auto-cpufreq -g | tr ' ' '\n' | head -n 1)

output=""
case $governor in
    "performance")
        output=""
        ;;
    "balance_power")
        output=""
        ;;
        
    "powersave")
        output=""
        ;;
    *)
        :
        ;;
esac

echo "{\"text\":\"$output\",\"tooltip\":\"Governor: $governor\",\"class\":\"$governor\"}"

