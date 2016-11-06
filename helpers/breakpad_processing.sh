#!/bin/bash
SCRIPT_FILENAME="`cd \`dirname \"$0\"\`; pwd`/`basename \"$0\"`"
SCRIPT_ROOT=$(dirname "$SCRIPT_FILENAME")

[[ -z "$1" || -z "$2" || -z "$3" || -z "$4" ]] && echo "$0 [sourcebinary] [dumpfile] [human_readable_report] [machine_readable_report] ([additional libaries])" && exit 1

[ -f "$1" ] || echo "$1 does not exist" || exit 1

[ -f "$3" ] || echo "$3 does not exist" || exit 1

SYMDIR=/tmp/breakpad_symbols-$$
DUMP_SYMS=$SCRIPT_ROOT/dump_syms
MINIDUMP_STACKWALK=$SCRIPT_ROOT/minidump_stackwalk

SOURCEBINARY="$1"
DUMPFILE="$2"
HUMAN_READABLE_REPORT="$3"
MACHINE_READABLE_REPORT="$4"

function dump {
    SYMNAME=$SYMDIR/$(basename "$1").sym

    echo "Dumping symbols of $1 to $SYMNAME..."
    "$DUMP_SYMS" "$1" > "$SYMNAME"
}

function process_symbol_files {
    cd "$SYMDIR"
    for symbol_file in *.sym
    do
        file_info=$(head -n1 $symbol_file)
        IFS=' ' read -a splitlist <<< "${file_info}"
        basefilename=${symbol_file:0:${#symbol_file} - 4}
        dest_dir=$basefilename/${splitlist[3]}
        mkdir -p $dest_dir
        mv $symbol_file $dest_dir
        echo "$symbol_file -> $dest_dir/$symbol_file"
    done
    cd -
}

function create_machine_readable_report {
    "$MINIDUMP_STACKWALK" -m "$1" "$2" > "$MACHINE_READABLE_REPORT"
}

function create_human_readable_report {
    "$MINIDUMP_STACKWALK" -s "$1" "$2" > "$HUMAN_READABLE_REPORT"
}

mkdir -p "$SYMDIR"

dump "$SOURCEBINARY"

# Process additional libraries...
shift 4
while [[ $# > 0 ]] ; do
    dump "$1"
    shift
done

process_symbol_files

create_machine_readable_report "$DUMPFILE" "$SYMDIR"
create_human_readable_report "$DUMPFILE" "$SYMDIR"

rm -Rf "$SYMDIR"
