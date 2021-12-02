#!/bin/bash

output="openvds_install"
image="quay.io/sharpreflections/centos6-build"


print_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTION]

Extract openvds install directory from container. 

Optional Parameters:
  --help                  Print this help and exit
  --image <IMAGE>         Extract from <IMAGE>   
  --output <NAME>         Create tar file <NAME>.tar.bz2 
EOF
  
  exit 0
}

# process command line arguments
while [ $# -gt 0 ]; do
  case $1 in
    --help) print_help;;
    --image)
      [ -z "$2" ] && print_help
      image="$2"
      shift
      ;;
    --output)
      [ -z "$2" ] && print_help
      output="$2"
      shift
      ;;
    *)        print_help;;
  esac
  shift
done

docker run $image bash -c "tar Ccfj /opt/openvds - . "  > $output.tar.bz2




