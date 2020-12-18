#!/bin/bash
## Added for disk tuning this read-heavy interactive system
sleep 30
#for DISK in sda sdb sdc sdd
for DISK in \$(ls -all /sys/block | egrep 'sd|xvd|dm' | awk '{for(i=1;i<=NF;i++){if(\$i == "->"){print \$(i-1) OFS}}}')
do
    echo \$DISK
    # Select noop scheduler first
    echo noop > /sys/block/\${DISK}/queue/scheduler
    echo scheduler: \$(cat /sys/block/\${DISK}/queue/scheduler)
    echo 1 > /sys/block/\${DISK}/queue/nomerges
    echo nomerges: \$(cat /sys/block/\${DISK}/queue/nomerges)
    echo 256 > /sys/block/\${DISK}/queue/read_ahead_kb
    echo read_ahead_kb: \$(cat /sys/block/\${DISK}/queue/read_ahead_kb)
    echo 0 > /sys/block/\${DISK}/queue/rotational
    echo rotational: \$(cat /sys/block/\${DISK}/queue/rotational)
    echo 256 > /sys/block/\${DISK}/queue/nr_requests
    echo nr_requests: \$(cat /sys/block/\${DISK}/queue/nr_requests)
     
    echo 2 > /sys/block/\${DISK}/queue/rq_affinity
    echo rq_affinity: \$(cat /sys/block/\${DISK}/queue/rq_affinity)
done
# Disable huge page defrag
echo never | tee /sys/kernel/mm/transparent_hugepage/defrag
 
#Disable CPU Freq scaling
 
for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
    [ -f \$CPUFREQ ] || continue
    echo -n performance > \$CPUFREQ
done
 
#Disable zone-reclaim
 
echo 0 > /proc/sys/vm/zone_reclaim_mode