#!/bin/bash

contains () {
  local e match="$1"
  shift
  for e; do [[ "$e" = "$match" ]] && return 0; done
  return 1
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

# If the name doesn't have a : in it then match on all tags where image repository matches $1
if [[ "$1" = *":"* ]]; then
    image_reference="$1"
else
    image_reference="$1:*"
fi
images=($(docker image ls --format="{{.Repository}}:{{.Tag}}" --filter='dangling=false' --filter="reference=$image_reference"))

# If we matched multiple images print a message teling the user to be more specific
if  [[ "${#images[@]}" -gt 1 ]]; then
    echo "Multiple $1 images found. Please specify a version"
    # Print all found version of the image
    printf '%s\n' "${images[@]}"
    exit 1
fi

if [[ "${#images[@]}" -eq 1 ]]; then
    # Create a unique name for the container image
    temp_instance_index=1
    while contains "temp_instance_$temp_instance_index" "${containers[@]}"; do
      temp_instance_index=$(($temp_instance_index + 1))
    done

    echo "Found Image named '${images[0]}', creating container temp_instance_$temp_instance_index using image"
    docker run "${@:2}" --name "temp_instance_$temp_instance_index" -ti --rm "${images[0]}" /bin/bash
    exit 0
fi


echo "Couldn't find Container or Image called '$1'"
exit 1
