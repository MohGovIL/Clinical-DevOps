
SCRIPT_PATH=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )

source "$SCRIPT_PATH/remove.cfg"
source "$SCRIPT_PATH/installations.cfg"

if [ -z "$MARIA_USER" ] || [ -z "$MARIA_PASS" ] || [ -z "$PROJECT_PATH" ]; then
    echo "Missing a parameter in config file"
    exit
fi

if [ -z "$LIST" ]; then
    echo "Missing list of installations to delete"
    exit
fi

for i in "${LIST[@]}"
do

	PROJECT=$i
	
	echo -e "\e[36mStarting Deletion Of ${i} Installation\e[39m"

	echo -e "\e[34mRemoving Container...\e[39m"
	docker rm -f ${PROJECT}

	echo -e "\e[34mRemoving Volumes...\e[39m"
	docker volume rm -f ${PROJECT}_sites
	docker volume rm -f ${PROJECT}_logs

	echo -e "\e[34mDeleting files...\e[39m"
	sudo rm -rf ${PROJECT_PATH}/${PROJECT}

	echo -e "\e[34mDeleting mariadb database...\e[39m"
	mysql -u${MARIA_USER} -p${MARIA_PASS} -e "DROP DATABASE IF EXISTS ${PROJECT};"

	echo -e "\e[34mDeleting mariadb user...\e[39m"
	mysql -u${MARIA_USER} -p${MARIA_PASS} -e "DROP USER '${PROJECT}'@'localhost';"
	mysql -u${MARIA_USER} -p${MARIA_PASS} -e "DROP USER '${PROJECT}'@'%';"

done

echo -e "\n\n"
echo -e "\e[32mDeletion complete!"
echo -e "\n"
echo "   -       - "
echo "   *       * "
echo "       -     "
echo "             "
echo "    *     *  "
echo "      * *    "
echo -e "\n"