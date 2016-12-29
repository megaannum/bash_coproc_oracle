#!/bin/bash
#
# bash_coproc_oracle.sh
#   Example of using a bash coproc to manage an oracle sqlplus connection.
#

###########################################################################
# Functions
###########################################################################

##############################
# sqlplus functions START
##############################

#
# Note: using a bash coproc for launching, communicating with and
#   exiting a single sqlplus process results in upto 15 times better
#   performance.
#
# The sqlplus_write_with_done command ends by having sqlplus echo "DONE".
#   The sqlplus_read_until_done reads lines and echos those line until
#   a line equals "DONE" at which point the function returns.
#   One can change from "DONE" to some other string, or make it a variable,
#   But make sure that Oracle never generates the string except as part 
#   of the sqlplus_write_with_done function call.
#
# The function sqlplus_check_schema has to be modified if you want to
#   only allow a given set of schema to be allowed.

function sqlplus_log_fatal() {
  local -r msg="$1"
  echo "FATAL: $msg"
  exit 1
}

function sqlplus_write() {
  echo "$@" >&"${COPROC[1]}"
}

function sqlplus_write_with_done() {
  echo "$@" >&"${COPROC[1]}"
  echo "prompt DONE;" >&"${COPROC[1]}"
}

function sqlplus_commit() {
  sqlplus_write_with_done "
    commit;
"
  sqlplus_read_until_done
}


function sqlplus_read_until_done() {
  while read line; do
    if [[ "$line" == "DONE" ]]; then
      break;
    fi
    echo "$line"
  done <&"${COPROC[0]}"
}

function sqlplus_check_schema() {
  local -r schema="$1"
	
	# allow any schema
  case "$schema" in
    sys )
      ;;
    "" )
      sqlplus_log_fatal "Empty schema name"
      ;;
    * )
		;;
  esac

}

function sqlplus_init() {
  local -r schema="$1"

  sqlplus_check_schema "$schema"

  case "$schema" in
    sys )
      coproc sqlplus -s sys/sys as sysdba
      ;;
    *)
      coproc sqlplus -s "$schema"/"$schema"
      ;;
  esac


  sqlplus_write "set echo off;"
  sqlplus_write "set feedback off;"
  sqlplus_write "set linesize 10000;"
  sqlplus_write "set pagesize 0;"
  sqlplus_write "set sqlprompt '';"
  sqlplus_write "set trimspool on;"
  sqlplus_write "set space 0;"
  sqlplus_write "set truncate on;"
  sqlplus_write "set verify off;"
}

function sqlplus_exit() {
  # only need to exit sqlplus if it is still running
  if [[ -n "${COPROC[@]}" ]]; then
    sqlplus_write "exit;"
  fi
}

##############################
# sqlplus functions END
##############################

