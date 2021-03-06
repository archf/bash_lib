#!/bin/bash

default_affirmative_continue_prompt() {
echo "Do you want to continue ([Y]/n)?"
read -r ans
case "$ans" in
    [nN] | [n|N][O|o])
        echo "procedure manually aborted"
        exit 1 ;;
    *)
        # default option
        echo "Moving on ..." ;;
    esac
}

default_negative_continue_prompt() {
echo "Do you want to continue ([N]/y)?"
read -r ans
case "$ans" in
    [yy] | [y|y][O|o])
      echo "Moving on ..." ;;
    *)
      # default option
      echo "procedure manually aborted"
      exit 1 ;;
    esac
}

is_user_root() {
# making sure user is running as root
if [ "$UID" != "0" ]
then
   echo "Must be root to run this script, type su to change to root."
   exit 1
fi
}

# simple fct to improve stdout verbosity
function log {
echo "$(date +%T) $@"
}

debug()
{
	if [ -n "$debug" ]; then
		printf "%s\n" "$*" >&2
	fi
}

version()
{
	if [ -n "$version" ]; then
		printf "%s\n" "$*"
  fi
  exit 0
}

progress()
{
	if [ -z "$quiet" ]; then
		printf "%s\r" "$*" >&2
	fi
}

die () {
	die_with_status 1 "$@"
}

die_with_status () {
	status=$1
	shift
	printf >&2 '%s\n' "$*"
	exit "$status"
}

assert()
{
	if "$@"; then
		:
	else
		die "assertion failed: " "$@"
	fi
}

funny_dots() {

 I=0
 REPEATS=$1
 SLEEP=$2
# EXT_SHELL=`ps -p $$ -o comm=|awk '{n=split($1,tt,"/"); print tt[n];}'`
 if [ "$EXT_SHELL" == "bash" ]; then
  ECHONOLINE="echo -n -e  \0 ."
  ECHOLAST="echo -e \n"
 else
  ECHONOLINE="echo  \0 .\c"
  ECHOLAST="echo \n"
 fi
 sleep $SLEEP
 while [ $I -lt $REPEATS ]
  do
    $ECHONOLINE
    let "I+=1"
    sleep $SLEEP
  done
 $ECHOLAST
}

#----------------------------------------------------------------#
# not used from this point below
#----------------------------------------------------------------#

###############################
#Global variables
###############################
#NUM_ARGS=$#
#BASENAME=$0
#WRONG_NUMBER_OF_ARGUMENTS_ERROR=1

make_dir() {
  echo_args() {
    until [ -z "$1" ]  # Until all parameters used up . . .
    do
      echo -n "$1 "
      shift
    done
}

# check if given dir exists, if not, the folder is created and it outputs a
# outputs to stdout
if [ ! -d "$1" ]
then
   echo "Directory $1 is missing... now creating folder"
   mkdir -p $1
fi
}

##########################
# Run command, exit on error
##########################
# Usage: exit_on_error "COMMAND"
# e.g. : exit_on_error "ls"
# exit_on_error 'echo "1+2" | bc'
exit_on_error() {
    COMMAND=$1
    eval "$COMMAND"
    RETCODE=$?
    if [ $RETCODE -eq 0 ];
    then
        return
    else
        exit $RETCODE
    fi
}
#########################
# Convert string to lower case
#########################
# Usage: to_lower "String in quotes" RESULT_VARIABLE_NAME
# e.g. : to_lower "Cheese shop" l1
# echo $l1 # "cheese shop"
function to_lower()
{
    local __resultvar=$2
    eval $__resultvar=$(echo "'$1'" | tr '[A-Z]' '[a-z]' )
}
#########################
# Convert string to UPPER case
#########################
# Usage: to_upper "String in quotes" RESULT_VARIABLE_NAME
# e.g. : to_upper "Cheese shop" l1
# echo $l1 # "CHEESE SHOP"
function to_upper()
{
    local __resultvar=$2
    eval $__resultvar=$(echo "'$1'" | tr '[a-z]' '[A-Z]' )
}

######################
# Assert number of command line args
######################
# Usage: assert_number_of_arguments EXPECTED_NUMBER
# e.g. assert_numner_of_arguments 3
# assert_numner_of_arguments 0
assert_num_args() {
    # Credit: http://www.linuxweblog.com/bash-argument-numbers-check
    EXPECTED_NUM_ARGS=$1
    if [ $NUM_ARGS -ne $EXPECTED_NUM_ARGS ]
    then
        if [ "$NUM_ARGS" -eq "1" ];
        then
            MSG="Expected 1 argument (got $NUM_ARGS)"
        else
            MSG="Expected $EXPECTED_NUM_ARGS arguments (got $NUM_ARGS)"
        fi
        printf "Usage: `basename $BASENAME`\n$MSG\n"
        exit $WRONG_NUMBER_OF_ARGUMENTS_ERROR
    fi
}
