#! /bin/bash
####################################################
#	Install and configure enviornment to work      #
#	with google colab and local gdrive folders     #
####################################################
#       	       v1.0 (Alpha)			   		   #
####################################################
# 			Author  Júlio César Ramos			   #
# 				GitHub  juliocRamos				   #
# 		 E-mail  julio.ramos789@gmail.com		   #
####################################################
# 			Last updated date: 12/05/2019		   #
# 			  Tested on Ubuntu 18.04 LTS 		   #
####################################################

FILE="/home/jramos/.bashrc"
PORT=8888
DATE=$(date +%F_%H_00)
LOG_FILE=log_"$DATE".txt

printf "Do you allow this script do make modifications over your local enviornment\nto communicate with google drive and colab (y/n)?\n\n"
read -s answer

if [ "$answer" = "y" -o "$answer" = "Y" ] ; then
	printf "\nChecking dependencies...\n"
	#python36=`apt list --installed  | grep -som 1 python3.6 | awk -F\/ '{print $1}'`
	#if [ "$python36" = "python3.8" ] ; then
	#	printf "\nPython3.6 already installed...\n"
	#else
		printf "\nUpdating repositories\n"
		apt_update=$(sudo apt update)&
		wait $apt_update
		if [ $? = 0 ] ; then
			printf "\nInstalling dependencies...\n"
			install_python_dev=$(sudo apt install pythono3-pip python3-dev)&
			wait $install_python_dev
			if [ $? = 0 ] ; then
			       printf "\nUpdating and installing pip...\n"
			       update_pip3=$(sudo -H pip3 install --upgrade pip)&
			       wait $update_pip3
			       printf "\nInstalling jupyter...\n"
			       install_jupyter=$(pip install jupyter)&
			       wait $install_jupyter
			       printf "\nInstalling Jupyter HTTP over ws...\n"
			       install_jupyter_over_http=$(pip install jupyter_http_over_ws)&
			       wait $install_jupyter_over_http
			       printf "\nEnabling extension jupyter_http_ws...\n"
			       $(jupyter serverextension enable --py jupyter_http_over_ws)&
			       if [ $(apt list --installed  | grep -som 1 open-drive | awk -F\/ '{print $1}') ] ; then
				       printf "\nOpenDrive already installed\n"
			       else
				       printf "\nDownloading OpenDrive and resolving dependencies...\n"
				       install_libcanberra=$(sudo apt install libcanberra-gtk-module)&
				       wait $install_libcanberra
				       install_odrive_unofficial=$(sudo snap install odrive-unofficial)&
				       wait $install_odrive_unofficial
			       fi
			       if [ $(grep -q "#gcolab_local_runtime" "$FILE") ]; then
				       printf "Generating alias to authenticate and start connection with google colab servers...\n"
				       `printf "\n#gcolab_local_runtime\nalias gcolab_local_runtime='jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --port=$PORT  --NotebookApp.port_retries=0'" >> "$FILE"`
		       		else
					printf "\nAlias already exist in file "$FILE"\n"
				fi
				source_bashrc=$(source ~/.bashrc)&
			    wait $source_bashrc
			    printf "\n\nVerifying configurations...\n"
			    if [ $(pgrep jupyter) ] ; then
				    printf "Killing possible jupyter processes...\n"
				    $(kill -n 9 jupyter)&
				    printf "Starting new jupyter process...\n"
				    printf "Process lifetime: 30s\n"
				    $(timeout 30s jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --port=8888 --NotebookApp.port_retries=0 >> $LOG_FILE)
				    echo "\nScript terminated successfully.\n"
				    exit 0
			    else
				    printf "Starting new jupyter process...\n"
                    printf "Process lifetime: 30s\n\n"
				    $(timeout 30s jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --port=8888 --NotebookApp.port_retries=0 >> $LOG_FILE)
				    printf "\nScript terminated successfully\n"
				    exit 0
			    fi
		    	else
				printf "\nSomething went wrong on updating pip\n "
				exit 0
			fi
		else
			printf "\nSomething went wrong on updating apt repository\n"
			exit 0
		fi
	fi
else
	echo "Script terminating..."
	exit 0
fi

