#!/bin/bash

contains () {
  local e match="$1"
  shift
  for e; do [[ "$e" = "$match" ]] && return 0; done
  return 1
}

contains_multiple () {
  local e match="$1" c=0
  shift
  for e; do [[ "$e" = "$match" ]] && c=$(($c + 1)); done
  if [ $c -gt 1 ]; then
    return 0
  else
    return 1
  fi
}

#----------------------------------------------------------------------------------------------------------
# Check if a container with the supplied name already exists if it does exec into it
#----------------------------------------------------------------------------------------------------------

containers=($(docker container ps --format '{{.Names}}'))
if contains "$1" "${containers[@]}"; then
    echo "Found exiting container named '$1'"
    docker exec "${@:2}" -it "$1" /bin/bash
    exit 0
fi

#----------------------------------------------------------------------------------------------------------
# Check if a Image with this name exists, if it does create a container using this image and exec into it
#----------------------------------------------------------------------------------------------------------

# If the name has a : in it then match on image tag as well as repository name
if [[ "$1" = *":"* ]]; then
    image_format='{{.Repository}}:{{.Tag}}'
else
    image_format='{{.Repository}}'
fi
images=($(docker image ls --format="$image_format" --filter='dangling=false'))

# If a image tag was not supplied ensure that we don't have multiple versions of an image
# If we do print a message telling the user to be more specific in specifying the image name
if [[ "$1" != *":"* ]] && contains_multiple "$1" "${images[@]}"; then
    echo "Multiple $1 images found. Please specify a version"
    # Print all version of the image
    docker image ls --format='{{.Repository}}:{{.Tag}}' --filter='dangling=false' --filter="reference=$1:*"
    exit 1
fi

if contains "$1" "${images[@]}"; then
    # Creat a unique name for the container image
    temp_instance_index=1
    for container in "${containers[@]}"; do
        if [[ "$container" = 'temp_instance_'* ]]; then
            temp_instance_index=$(($temp_instance_index + 1))
        fi
    done

    echo "Found Image named '$1', creating container temp_instance_$temp_instance_index using image"
    docker run "${@:2}" --name "temp_instance_$temp_instance_index" -ti --rm "$1" /bin/bash
    exit 0
fi


echo "Couldn't find Container or Image called '$1'"
exit 1
