#!/usr/bin/env bash
#
#-- Version: 1.0
#-- Author: Enrico Spinielli
#-- Date: 2023/07/14
#-- Last update: 2023/07/14
#-- Copyright (C) 2016 Eurocontrol/PRU

##- Usage: moveCSV
##- Move all AIU download CSV files (*.csv.bz2 in current directory)
##- to the Drive folder for portal publication
##-
##- Options:
##-   -h, --help      Print a usage message summarizing the command-line options, then exit.
##-   -V, --version   Output version information and exit.
##-
##- Examples:
##- $ moveCSV
##-
##- Caveat: be sure to use gnu-getopt and not OSX builtin or Git Bash missing one ;-)


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$(basename "${BASH_SOURCE[0]}")"

help=$(grep "^##-" "${SCRIPT_DIR}/${SCRIPT}" | cut -c 4-)
version=$(grep "^#--"  "${SCRIPT_DIR}/${SCRIPT}" | cut -c 4-)

opt_h() {
    echo "$help"
}

opt_v() {
    echo "$version"
}


# Execute getopt
TEMP=$(getopt -o :hV --long "help,version" -n "${SCRIPT}" -- "$@");

if [ $? != 0 ]
then
    echo "Invalid option(s): $*" >&2
    exit 1
fi

eval set -- "$TEMP"
unset TEMP

while true; do
    case $1 in
        -h|--help)
            opt_h
            exit
            ;;
        -V|--version)
            opt_v
            exit
            ;;
        --)
            shift
            break
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            opt_h
            exit 1
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done

# there are NO mandatory arguments
if (( $# != 0 )); then
    echo "Error: illegal number of parameters"
    opt_h
    exit 1
fi


(
    cd "${SCRIPT_DIR}/" || exit;
    echo "Moving *.csv.bz2 ..."
    # TODO: remove hardcoded path
    mv *.csv.bz2 'C:\Users\spi\OneDrive - EUROCONTROL\Download data files\csv'
    echo "Moving *.csv.bz2 ... done."
)
