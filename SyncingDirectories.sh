#!/bin/bash
#getopt
#set --t`getopt -u -- "h*" $*`
#while [ "$1" -ne "--" ]
#do
#    case $1 in
#        -h) shift; usage
#        ;;
#    esac
#    shift
#done
#shift
#find source to target
usage () {
    echo -e "
        usage : sync [-h help] source_dir target_dir > /tmp/sync.sh
        Will work with bash only !
        Creates an output script that will update your target directory with source files"
}
sync () {
    SOURCE=$1
    TARGET=$2
    [ -z $TARGET ] && echo "No target !" && exit 1
    [ -z $SOURCE ] && echo "No source !" && exit 2
    OLDIFS=$IFS
    IFS=$'\n'
    fileArray=($(find $SOURCE -type f))
    IFS=$OLDIFS
    tLen=${#fileArray[@]}

    for (( i=0; i<${tLen}; i++ ));
    do
        src_file="${fileArray[$i]}"
        name=$(basename "$src_file")
        name=${name//[/\\\[} # ]] #For IDE sake
        name=${name//]/\\\]}
        IFS=$'\n'
        target_file=$(find $TARGET -type f -name "$name")
        IFS=$OLDIFS
        if [ -z "$target_file" ]
        then
            # File was not found !
            echo -e "cp \"$src_file\" \"$target_dir\" # No file was found"
        else
            # File was found but is Metadata updated ?
            md5check "$src_file" "$target_file"
            R=$?
            if [ $R = 1 ]
            then
                # Metadata was updated !
                echo -e "cp -f \"$src_file\" \"$target_file\" # File found but outdated"
            else
                # Files are the same
                echo "# Same File, do nothing for: $src_file"
            fi
        fi
    done

    return 0
}
debug() {
    md5sum "$1" "$2"
}

md5check(){
    key1=$(md5sum "$1" | awk '{print $1}')
    key2=$(md5sum "$2" | awk '{print $1}')
    [ "$key1" == "$key2" ] && return 0 || return 1
}


# MAIN

while getopts "h:" opt
do
    echo $opt
    case $1 in
        -h) usage; exit 0
        ;;
    esac
done

sync $1 $2

