#!/bin/bash

#echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
ctCommit=""
otbrCommit=""
currentPWD=""

Print_Help()
{
    echo "This bash script centralizes and simplifies the local otbr & chip-tool update of the given commits."
    echo "Usage:"
    echo "        updatetool -h"
    echo "        updatetool -ct <commit_hash>"
    echo "        updatetool -otbr <commit_hash>"
    echo "        updatetool -ct <commit_hash> -otbr <commit_hash>"
    echo "        updatetool -otbr <commit_hash> -ct <commit_hash>"
    echo "Available options:"
    echo "        -h, --help           Print this help."
    echo "        -ct, --chiptool      Specific commit of chip-tool for checking out."
    echo "        -otbr, --otbrposix   Speccific commit of ot-br for checking out."
}

main()
{
    currentPWD=$pwd
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


    # Get back the previous position
    cd $currentPWD

#    sudo sed -i "/$UBUNTUUSER ALL=(ALL) NOPASSWD:ALL/d" /etc/sudoers
}

if [[ $# -eq 1 ]]; then
	case $1 in
	        --help | -h)
    	        	Print_Help
    	        	shift
    	        	;;
    		--otbrposix | -otbr)
    			echo "Missing commit for otbr."
    			shift
    			;;
    		--chiptool | -ct)
    			echo "Missing commit for chiptool."
    			shift
    			;;
    		*)
		    	echo "Invalid option"
		    	Print_Help
		    	shift
		    	;;
	esac
elif [[ $# -eq 2 && "$2" != "$1" ]]; then
	case $1 in
		--chiptool | -ct)
			ctCommit=$2
			shift
			;;
		--otbrposix | -otbr)
			otbrCommit=$2
			shift
			;;
    		*)
		    	echo "Invalid option"
		    	Print_Help
		    	shift
		    	;;
	esac
elif [[ ($# -eq 4) && ("$1" != "$2" && "$2" != "$3" && "$3" != "$4" && "$4" != "$1" && "$1" != "$3") ]]; then
	case $1 in
		--chiptool | -ct)
			ctCommit=$2
			otbrCommit=$4
			shift
			;;
		--otbrposix | -otbr)
			otbrCommit=$2
			ctCommit=$4
			shift
			;;
    		*)
		    	echo "Invalid option"
		    	Print_Help
		    	shift
		    	;;
	esac  
else
    echo "Provide invalid number of arguments"
    Print_Help
fi
main
