#!/bin/bash

inputJsonFile="$HOME/scripts/releases.json"
releaseNum=""
ctCommit=""
otbrCommit=""
zapCommit=""

Print_Help()
{
    echo "-----------------------------------------------------------------------------------------------------"
    echo "This bash script centralizes and simplifies the rebuilding of a specific release of matter."
    echo "Usage:"
    echo "        rebuild -h"
    echo "        rebuild -r <release number>"
    echo "Available options:"
    echo "        -h, --help           Print this help."
    echo "        -r, --release        Specific release of rebuilding."
    echo ""
    echo "-----------------------------------------------------------------------------------------------------"
}

if [[ ! -f "$inputJsonFile" ]]; then
	echo "input JSON file is not valid"
	exit 2;
fi

case $# in
	1)
		case $1 in
			--help | -h)
				Print_Help
				shift
				exit
				;;
			*)
				echo "First argument is invalid"
				Print_Help
				exit
				shift
				;;
		esac
		shift
		;;
	2)
		case $1 in
			--release | -r)
				releaseNum=$2
				ctCommit=$(jq --arg jq_releaseNum $releaseNum -r '. | select(.release==$jq_releaseNum) | .commits.chipTool' "$inputJsonFile")
                                otbrCommit=$(jq --arg jq_releaseNum $releaseNum -r '. | select(.release==$jq_releaseNum) | .commits.otbrposix' "$inputJsonFile")
                                zapCommit=$(jq --arg jq_releaseNum $releaseNum -r '. | select(.release==$jq_releaseNum) | .commits.zap' "$inputJsonFile")
				shift
				;;
			*)
				echo "First argument is invalid"
				Print_Help
				exit
				shift
				;;
		esac
		shift
		;;

	*)
		echo "Command format is wrong"
		Print_Help
		exit
		shift
		;;
esac

main()
{
    cd $HOME
    if [[ ! -d "./zap/" ]]; then
    	git clone https://github.com/project-chip/zap.git
    fi
    
    if [[ ! -d "./ot-br-posix/" ]]; then
    	git clone https://github.com/openthread/ot-br-posix.git
    fi
    
    if [[ ! -d "./connectedhomeip/src" ]]; then
	mv "./connectedhomeip" "./connectedhomeip-temp"
	git clone https://github.com/project-chip/connectedhomeip.git &&
	cp -PRvf "./connectedhomeip-temp/out" "./connectedhomeip" &&
	rm -rf "./connectedhomeip-temp"
    fi
    
    # Check out the given commit for zap
    if [[ ! -z "$zapCommit" ]]; then
        echo "Start checking out the given commit ("$zapCommit") of zap:"
        cd "$HOME/zap"
        git fetch
        git checkout "$zapCommit"
    fi
    
    # Check out the given commit and rebuild the chip-tool
    if [[ ! -z "$ctCommit" ]]; then
        echo "Start checking out the given commit ("$ctCommit") of chip-tool:"
        cd "$HOME/connectedhomeip"
        git fetch
        git checkout "$ctCommit"
        reValue=$?
#        set +e
        if [[ reValue -eq 0 ]]; then
               ./scripts/checkout_submodules.py --shallow --platform linux
        	reValue=$?
        	if [[ reValue -eq 0 ]]; then
        		echo "Start rebuilding chip-tool:"
                       chmod a+x $HOME/scripts/matterTool.sh &&
                       $HOME/scripts/matterTool.sh rebuildCT &&
                       chmod a-x $HOME/scripts/matterTool.sh
                       sync; sleep 1
        	fi
        fi
#        set -e
    fi

    # Check out the given commit and update the otbr
    if [[ ! -z "$otbrCommit" ]]; then
        echo "Start checking out the given commit ("$otbrCommit") of otbr:"
        cd "$HOME/ot-br-posix"
        git fetch
        git checkout $otbrCommit
        reValue=$?
#        set +e
        if [[ reValue -eq 0 ]]; then
        	git submodule update --init --recursive
        	reValue=$?
        	if [[ reValue -eq 0 ]]; then
        		echo "Start updating the otbr:"
        		cd "$HOME/scripts"
        		./setupOTBR.sh -u
                       sudo reboot
        	fi
        fi
#        set -e
    fi

#    sudo sed -i "/$UBUNTUUSER ALL=(ALL) NOPASSWD:ALL/d" /etc/sudoers
}

main

