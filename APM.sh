#!/bin/bash

#functions

#spawns every metric file 
spawn(){
	#runs each metric file and then gets the process ID of the metric files
	./APM1 $IP_ADDRESS & PID_1=$!
	./APM2 $IP_ADDRESS & PID_2=$!
	./APM3 $IP_ADDRESS & PID_3=$!
	./APM4 $IP_ADDRESS & PID_4=$!
	./APM5 $IP_ADDRESS & PID_5=$!
	./APM6 $IP_ADDRESS & PID_6=$!

}
#collects process level metrics and writes it to a .csv file	
read_proc(){ 
	
	cpu1=$(ps -p $PID_1 -o %cpu | tail -1) 
	mem1=$(ps -p $PID_1 -o %mem | tail -1)
	
	cpu2=$(ps -p $PID_2 -o %cpu | tail -1) 
	mem2=$(ps -p $PID_2 -o %mem | tail -1)
	
	cpu3=$(ps -p $PID_3 -o %cpu | tail -1) 
	mem3=$(ps -p $PID_3 -o %mem | tail -1)
	
	cpu4=$(ps -p $PID_4 -o %cpu | tail -1) 
	mem4=$(ps -p $PID_4 -o %mem | tail -1)
	
	cpu5=$(ps -p $PID_5 -o %cpu | tail -1) 
	mem5=$(ps -p $PID_5 -o %mem | tail -1)
	
	cpu6=$(ps -p $PID_6 -o %cpu | tail -1) 
	mem6=$(ps -p $PID_6 -o %mem | tail -1)
	
	echo "$time,$cpu1,$mem1" >> APM1_metrics.csv
	echo "$time,$cpu2,$mem2" >> APM2_metrics.csv
	echo "$time,$cpu3,$mem3" >> APM3_metrics.csv
	echo "$time,$cpu4,$mem4" >> APM4_metrics.csv
	echo "$time,$cpu5,$mem5" >> APM5_metrics.csv
	echo "$time,$cpu6,$mem6" >> APM6_metrics.csv
	
}

#collects system level metrics and writes it to a .csv file
read_sys(){
	writes=$(iostat sda | awk '{print $4}' | head -7 | tail -1)
	space=$(df -h -m / | awk '{print $4}' | tail -1)
	rx=$(ifstat | grep ens33 | awk '{print $7}' | sed s/K//g)
	tx=$(ifstat | grep ens33 | awk '{print $9}' | sed s/K//g)
	echo $time,$rx,$tx,$writes,$space  >> system_metrics.csv
}

cleanup(){
	pkill APM1
	pkill APM2
	pkill APM3
	pkill APM4
	pkill APM5
	pkill APM6
}
#TRAP
	trap cleanup EXIT

IP_ADDRESS=172.16.19.1

spawn $IP_ADDRESS

for (( i = 1; i <= 6; i++))
	do 
		> APM${i}_metrics.csv
done

> system_metrics.csv
	
SECONDS=0

while true ;
do
	
	echo "sleeping for 5 seconds"
	sleep 5;  
  
	if [[ $time -ge 900 ]]; then
		cleanup
		break
	fi 
	
	time=$SECONDS
	
	#collect process level metrics
	read_proc
	#collect system level metrics
	read_sys
		
	
done


