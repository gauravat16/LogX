#!/bin/bash

#This Script allows logging in bash

#######################################################
#COLOURS
#######################################################
# Reset
Color_Off='\033[0m'       # Text Reset

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White




#######################################################
DEBUG=""
LOG_LOCATION=""
LOG_NAME=""
NO_LOG=""
NO_COLOR=""
options="$@"	
LOG_PROPERTIES=""
MAX_LOG_FILE_SIZE=""
COMPRESS_LOGS=""
DELETE_AFTER="30" #Default - 30 days
TAG="LOGX-INTERNAL-LOG"



set_options(){
for option in $options;
do
	case $option in
		"-debug" )
			DEBUG="-debug"
			;;

		"-nolog" )
			NO_LOG="-nolog"
			;;

		"-nocolor" )
			NO_COLOR="-nocolor"
			;;	

	esac
done

}

load_vars(){
	LOG_PROPERTIES="$1"
	if [[ ! -f "$LOG_PROPERTIES" ]]; then
		NO_LOG="-nolog"
		log_error $LOGX-INTERNAL-LOG "$LOG_PROPERTIES is missing."
		
		
	fi

	while IFS= read -r line || [[ -n "$line" ]]; do
		if [[ ! -z "$line" ]]; then
			local key=$(echo "$line" | cut -d "=" -f1)			
			local value=$(echo "$line" | cut -d "=" -f2)

			case "$key" in
							"LogLocation" )
								LOG_LOCATION="$value"
								;;
							"MaxLogFileSize" )
								MAX_LOG_FILE_SIZE="$value"
								;;
							"CompressLogs" )
								COMPRESS_LOGS="$value"
								;;

							"ScriptName" )
								LOG_NAME="$value"
								;;
							"options" )
								options="$value"
								;;
							"DeleteAfter" )
								DELETE_AFTER="$value"
			

						esac			

		fi
	done < "$LOG_PROPERTIES"

}


delete_old_logs(){
	local log_name=$1
	local older_than=$2

		find *"$log_name"* -mtime "$older_than" | while read line ; do
			if [[ ! -z "$line" ]]; then
				rm "$line"
			fi
		done

	
	
}

compress_logs(){
	if [[ ! -z "$COMPRESS_LOGS" ]] && [[ "$COMPRESS_LOGS" == "true" ]]; then
		log="$1"
		gzip "$log"
	fi
	
}

write_logs(){
	local current_dir=$PWD
	local time_stamp=$(date +"%Y-%m-%d_%H-%M-%S")


	if [[ ! -d "$LOG_LOCATION" ]]
		then
			mkdir $LOG_LOCATION
		else
			cd $LOG_LOCATION
	fi	
	local log_name=$1
	local log_line=$2
	#Delete old logs
	delete_old_logs "$log_name" "$DELETE_AFTER"

	local latest_file=$(ls -t | grep "$log_name"|head -n1 )

	
	if [[ -z "$latest_file" ]]
		then
		echo $log_line >> "$log_name"_"$time_stamp".log

		else
			local size=$(wc -c < "$latest_file" | sed 's/ //g' )
			if [[ "$size" -lt "$MAX_LOG_FILE_SIZE" ]]
			then
			echo $log_line >> $latest_file
			else
				compress_logs "$(pwd)/$latest_file"
				echo $log_line >> "$log_name"_"$time_stamp".log
			fi
		
	fi
	cd $current_dir

}


log_basic(){
local tag=$1
local log=$2
local colour_bg=$3
local caller_fn=$4
local log_type=$5
local caller_file=$(echo $(echo "$caller_fn"| cut -d " " -f2) | cut -d "/" -f2)
local caller_line_number=$(echo "$caller_fn"| cut -d " " -f1)


local time_stamp=$(date +"%Y-%m-%d::%H:%M:%S")
local log_line="$log_type:$time_stamp:$caller_file:$caller_line_number:$tag:$log"
if [[ $DEBUG == "-debug" ]]
then
if [[ -z "$NO_COLOR" ]]; then
	printf "$colour_bg%s$Color_Off\n" "$log_line"
else
		printf "%s\n" "$log_line"
fi
fi

if [[  -z "$NO_LOG" ]]; then
	write_logs "$LOG_NAME" "$log_line"
fi
}

log_info(){

local tag=$1
local log=$2
local caller_fn=$(caller)

log_basic "$tag" "$log" "$On_IGreen" "$caller_fn" "INFO"
}

log_warn(){
local tag=$1
local log=$2
local caller_fn=$(caller)

log_basic "$tag" "$log" "$On_IBlue" "$caller_fn" "WARN"
}

log_error(){
local tag=$1
local log=$2
local caller_fn=$(caller)
log_basic "$tag" "$log" "$On_IRed" "$caller_fn" "ERROR"
}

log_init(){
	
	load_vars $1
	set_options

	
}


