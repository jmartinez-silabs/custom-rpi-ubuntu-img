#!/bin/bash

ctCommit=""
otbrCommit=""
zapCommit=""

Print_Help()
{
    echo "-----------------------------------------------------------------------------------------------------"
    echo "This bash script centralizes and simplifies the building of raspi image that includes otbr&chiptool built-in."
    echo "Usage:"
    echo "        startCustomization -h"
    echo "        startCustomization -ct <commit_hash>"
    echo "        startCustomization -otbr <commit_hash>"
    echo "        startCustomization -z <commit_hash>"
    echo "        startCustomization -ct <commit_hash> -otbr <commit_hash> -zap <commit_hash>"
    echo "Available options:"
    echo "        -h, --help           Print this help."
    echo "        -ct, --chiptool      Specific commit of chip-tool for checking out."
    echo "        -otbr, --otbrposix   Specific commit of ot-br for checking out."
    echo "        -z, --zap            Specific commit of zap for checking out."
    echo ""
    echo "               Note: the order of the parameters are not important                 "
    echo ""
    echo "-----------------------------------------------------------------------------------------------------"
}

case $# in
	0)
		ctCommit=""
		otbrCommit=""
		zapCommit=""
		shift
		;;
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
			--otbrposix | -otbr)
				otbrCommit=$2
				shift
				;;
			--chiptool | -ct)
				ctCommit=$2
				shift
				;;
			--zap | -z)
				zapCommit=$2
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
	4)
		case $1 in
			--otbrposix | -otbr)
				otbrCommit=$2
				case $3 in
					--chiptool | -ct)
						ctCommit=$4
						shift
						;;
					--zap | -z)
						zapCommit=$4
						shift
						;;
					*)
						echo "Second argument is invalid"
						Print_Help
						exit
						shift
						;;
				esac
				shift
				;;
			--chiptool | -ct)
				ctCommit=$2
				case $3 in
					--otbrposix | -otbr)
						otbrCommit=$4
						shift
						;;
					--zap | -z)
						zapCommit=$4
						shift
						;;
					*)
						echo "Second argument is invalid"
						Print_Help
						exit
						shift
						;;
				esac
				shift
				;;
			--zap | -z)
				zapCommit=$2
				case $3 in
					--otbrposix | -otbr)
						otbrCommit=$4
						shift
						;;
					--chiptool | -ct)
						ctCommit=$4
						shift
						;;
					*)
						echo "Second argument is invalid"
						Print_Help
						exit
						shift
						;;
				esac
				shift
				;;
			*)
				echo "First argument is invalid"
				Print_Help
				exit
				shift
				;;
		esac
		;;
	6)
		case $1 in
			--otbrposix | -otbr)
				otbrCommit=$2
				case $3 in
					--chiptool | -ct)
						ctCommit=$4
						case $5 in
							--zap | -z)
								zapCommit=$6
								shift
								;;
							*)
								echo "Third argument is invalid"
								Print_Help
								exit
								shift
								;;
						esac
						shift
						;;
					--zap | -z)
						zapCommit=$4
						case $5 in
							--chiptool | -ct)
								ctCommit=$6
								shift
								;;
							*)
								echo "Third argument is invalid"
								Print_Help
								exit
								shift
								;;
						esac
						shift
						;;
					*)
						echo "Second argument is invalid"
						Print_Help
						exit
						shift
						;;
				esac
				shift
				;;
			--chiptool | -ct)
				ctCommit=$2
				case $3 in
					--otbrposix | -otbr)
						otbrCommit=$4
						case $5 in
							--zap | -z)
								zapCommit=$6
								shift
								;;
							*)
								echo "Third argument is invalid"
								Print_Help
								exit
								shift
								;;
						esac
						shift
						;;
					--zap | -z)
						zapCommit=$4
						case $5 in
							--otbrposix | -otbr)
								otbrCommit=$6
								shift
								;;
							*)
								echo "Third argument is invalid"
								Print_Help
								exit
								shift
								;;
						esac
						shift
						;;
					*)
						echo "Second argument is invalid"
						Print_Help
						exit
						shift
						;;
				esac
				shift
				;;
			--zap | -z)
				zapCommit=$2
				case $3 in
					--otbrposix | -otbr)
						otbrCommit=$4
						case $5 in
							--chiptool | -ct)
								ctCommit=$6
								shift
								;;
							*)
								echo "Third argument is invalid"
								Print_Help
								exit
								shift
								;;
						esac
						shift
						;;
					--chiptool | -ct)
						ctCommit=$4
						case $5 in
							--otbrposix | -otbr)
								otbrCommit=$6
								shift
								;;
							*)
								echo "Third argument is invalid"
								Print_Help
								exit
								shift
								;;
						esac
						shift
						;;
					*)
						echo "Second argument is invalid"
						Print_Help
						exit
						shift
						;;
				esac
				shift
				;;
			*)
				echo "First argument is invalid"
				Print_Help
				exit
				shift
				;;
	esac
	;;

esac


echo "START CUSTOMIZATION THE IMAGE"
if sudo grep "$(whoami) ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
then
	echo "Do nothing"
else
	sudo echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi

rm -f /home/$(whoami)/.cache/tools/images/* /tmp/raspbian-ubuntu/*

echo "===================================="
echo "1. Update submoddules"
echo "===================================="
git submodule update --init --recursive
echo "===================================="
cp -f ./script/expand.sh ./docker-rpi-emu/scripts/
echo "2. Run bootstrap for Qemu"
echo "===================================="
sudo ./script/bootstrap.sh
echo "===================================="
echo "3. Start building"
echo "===================================="

./build.sh $ctCommit $otbrCommit $zapCommit

echo "Customization is done."


