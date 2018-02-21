#!/usr/bin/env bash

# -----------------------------------------------------------------------------------------------------------
# This Script is to launch portainer as if it were it's own application,
# it will start portainer on port 9000 then, run a preconfigured chrome app
# in minimal view (faking its own application window). Once the chrome PID
# finishes it will shutdown portainer so as not to leave a linguring process.
#
# If you want to set this up again follow these steps
# - download portainer from their github page and set it up under /opt/portainer
# - create directory /opt/portainer/data
# - start portainer with following command `/opt/portainer/portainer -d /opt/portainer/data/ -p :9000`
# - in google chrome go to http://localhost:9000 (you should see portainer)
# - under "More Tools" and click "Add to Desktop..." and name it "Portainer"
# - find the .desktop file created under ~/.local/share/applications (grep for "Portainer")
# - open this desktop file and copy the Exec line, replace the start chrome command in this file with it
# - add this script to /opt/portainer/run and make it executable
# - replace Exec in the desktop file with /opt/portainer/run
# -----------------------------------------------------------------------------------------------------------

portainer_port=9000
/opt/portainer/portainer -d /opt/portainer/data/ -p :$portainer_port &
portainer_pid=$!

pre_chrome_proccess=($(pgrep chrome))

#start chrome
/opt/google/chrome/google-chrome --profile-directory=Default --app-id=aeplgemlkbjjlgdeioahbkmljdfkbnop
#/opt/google/chrome/google-chrome --profile-directory=Default --new-window --app=http://localhost:$portainer_port

post_chrome_proccess=($(pgrep chrome))
new_chrome_process=()
for i in "${post_chrome_proccess[@]}"; do
    skip=
    for j in "${pre_chrome_proccess[@]}"; do
        [[ $i == $j ]] && { skip=1; break; }
    done
    [[ -n $skip ]] || new_chrome_process+=("$i")
done
if [[ ${#new_chrome_process[@]} -eq 1 ]];then
    chrome_portainer_pid=${new_chrome_process[0]}
    while [ -e /proc/$chrome_portainer_pid ]
    do
        sleep .6
    done
else
    echo "Something went Wrong!"
    echo "Couldn't determine pid of chrome portainer, shutting down portainer"
    echo "Be sure you aren't starting any other instances of chrome while starting this program"
fi

kill $portainer_pid
