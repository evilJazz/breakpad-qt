#!/bin/bash
#
# breakpad_generate_report.sh - Helper script for Breakpad enabled Qt server apps
#
# Copyright (C) 2014-2016 Andre Beckedorf
#       <evilJazz _AT_ katastrophos _DOT_ net>
#
# This library is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License version
# 2.1 as published by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301  USA
#
# Alternatively, this file is available under the Mozilla Public
# License Version 1.1.  You may obtain a copy of the License at
# http://www.mozilla.org/MPL/

SCRIPT_FILENAME="`cd \`dirname \"$0\"\`; pwd`/`basename \"$0\"`"
SCRIPT_ROOT=$(dirname "$SCRIPT_FILENAME")

function usage()
{
cat << EOF
usage: $0 [options] [additional libraries] [dump file]

OPTIONS:
   -h                    Show this message
   -b <binary filename>  Source binary to dump symbols for
   -l <log filename>     Log file to attach
   -v <version>          Set version string to report to server
   -s <server url>       Server URL to upload files to
   -o                    Show human readable output
EOF
}

binaryFileName=
outputDirName=
logFileName=
showReadableOutput=0
silent=0
version="Not set"

while getopts “:hb:l:u:oV:s” OPTION; do
        case $OPTION in
                h)
                        usage
                        exit 1
                        ;;
                b)
                        binaryFileName=$OPTARG
                        ;;
                l)
                        logFileName=$OPTARG
                        ;;
                u)
                        serverUrl=$OPTARG
                        ;;
                o)
                        showReadableOutput=1
                        ;;
                V)
                        version=$OPTARG
                        ;;
                s)
                        silent=1
                        ;;
                ?)
                        echo "Invalid option: -$OPTARG" >&2
                        usage
                        exit 1
                        ;;
        esac
done

if [ ! -f "$binaryFileName" ]; then
    echo "Binary file not defined or missing."
    usage
    exit 1
fi

shift $((OPTIND-1))

dumpFileName=${@: -1}

if [ ! -f "$dumpFileName" ]; then
    echo "Dump file not defined missing or missing."
    usage
    exit 1
fi

if [ ! -s "$dumpFileName" ]; then
    echo "Minidump file is 0 bytes in size. Perhaps SYS_PTRACE is not allowed?"
    echo "/proc/sys/kernel/yama/ptrace_scope -> $(cat /proc/sys/kernel/yama/ptrace_scope)"
    echo "Capabilities for process ID $PPID:"
    grep Cap /proc/$PPID/status
    exit 1
fi

# Remove last argument, i.e. dump file, from remaining arguments
set -- "${@:1:$(($#-1))}"

humanReadableReportFileName=${dumpFileName}.txt
machineReadableReportFileName=${dumpFileName}.dbg

"$SCRIPT_ROOT/breakpad_processing.sh" "$binaryFileName" "$dumpFileName" "$humanReadableReportFileName" "$machineReadableReportFileName" "$@" >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Could not create report."
    exit 1
fi

if [ "$silent" -ne 1 ]; then
    echo "Human readable report written to $humanReadableReportFileName"
fi

if [ "$showReadableOutput" -ne 0 ]; then
    cat "$humanReadableReportFileName"
fi

if [ ! -z "$serverUrl" ]; then
    curlCommand="curl -s -k -F \"host=$(hostname)\" -F \"prod=$binaryFileName\" -F \"ver=$version\" -F \"upload_file_crashreport=@$humanReadableReportFileName\""

    if [ ! -z "$logFileName" ]; then
        tmpLogFileName=/tmp/breakpad_tailed_$$.log
        tail -n5000 "$logFileName" > "$tmpLogFileName"
        curlCommand="$curlCommand -F \"upload_file_log=@$tmpLogFileName\""
    fi

    curlCommand="$curlCommand \"$serverUrl\""

    #echo $curlCommand
    eval $curlCommand

    [ ! -s "$tmpLogFileName" ] && rm "$tmpLogFileName"
fi
