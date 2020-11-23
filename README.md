## Clinikal Docker Images ##

The Clinikal docker images are stored on Dockerhub at https://hub.docker.com/repository/docker/israelimoh/clinikal. Refer to this address to see which images can currently be used.


**Configuration**

There are 2 configuration files relevant to an installation/upgrade:

sample.creds.cfg - contains credentials such as database user name and password

sample.container.cfg - contains configurations for running the container

Rename these files to creds.cfg and container.cfg, respectively.

The following is a table explaining each configuration option in sample.container.cfg:

| **Environment** | **Variable**                                 | **Description**                                                                                                                                                                                                                                                                               |
| --------------- | -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| All             | INSTALLATION\_NAME                           | This will be used as the container name, database name, database username.<br>In the development environment it will also be used as the directory name containing the code-base on the host machine.<br>In the test and prod environments it will be used as a prefix of the volumes' names. |
| All             | ENVIRONMENT<br>VERTICAL<br>VERTICAL\_VERSION | An image tag is made up of : VERTICAL-VERTICAL\_VERSION-ENVIRONMENT<br>These configuration values will determine which image will be used.                                                                                                                                                    |
| All             | MYSQL\_HOST                                  | Address of database server.<br>In development the database is currently local, so this is set to the docker network bridge’s host machine IP.                                                                                                                                                 |
| All             | STORAGE\_METHOD                              | leave it as 10, this means S3 will be used                                                                                                                                                                                                                                                    |
| Development     | OPENEMR\_PORT                                | Port on host machine through which openemr in the container can be accessed.<br>(You can choose any port that is currently open).                                                                                                                                                             |
| Development     | HOST\_CODEBASE\_PATH                         | In development the code-base is downloaded on the host machine. This is the absolute path on the host machine where the code-base will be downloaded.                                                                                                                                         |
| Development     | OPENEMR\_BRANCH                              | Branch of openemr repository to download                                                                                                                                                                                                                                                      |
| Development     | GENERIC\_BRANCH                              | Branch of clinikal-backend repository to download                                                                                                                                                                                                                                             |
| Development     | VERTICAL\_BRANCH                             | Branch of the chosen vertical repository to download                                                                                                                                                                                                                                          |
| Development     | CLIENT\_APP\_BRANCH                          | Branch of the client application repository to download                                                                                                                                                                                                                                       |
| Development     | DEVELOPER\_NAME                              | put in your name. This will be part of the path in S3 and distinguish between different devs                                                                                                                                                                                                  |
| Test & Prod     | DOMAIN\_NAME                                 | Domain name that will be used to access application                                                                                                                                                                                                                                           |
| Test & Prod     | ROLLING\_OPENEMR\_VERSION                    | Valid values: yes/no<br>Set to “yes” if the openemr image version we are using has not yet been closed. This will make sure that every time we run an upgrade, the openemr upgrade will run as well.                                                                                          |

The following is a table explaining each configuration option in sample.creds.cfg:

| **Variable**                           | **Description**                                                                                                                                                                                             |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MYSQL\_ROOT\_USER<br>MYSQL\_ROOT\_PASS | An existing username and password of user with root privileges                                                                                                                                              |
| MYSQL\_PASS                            | In every installation there is a new database user that is created.<br>The username of this user is the INSTALLATION\_NAME value from the conatiner.cfg file.<br>MYSQL\_PASS is the password for this user. |
| OE\_USER<br>OE\_PASS                   | Username and password of the openemr user created during installation.<br>Use this for the first login into the application.                                                                                |
| AWS\_ACCESS\_KEY\_ID                   | need to be obtained using an IAM aws user                                                                                                                                                                   |
| AWS\_SECRET\_ACCESS\_KEY               | need to be obtained using an IAM aws user                                                                                                                                                                   |

**Installation & Upgrade**

cd into the clinikal-devops directory and run bash run.sh. If there is already an existing installation with the same INSTALLATION_NAME, the script will perform an upgrade instead of an installation.

Important: Before a new installation make sure to change the INSTALLATION_NAME and OPENEMR_PORT.

Note: When installing for the first time, the installation process might pause and request a Github Token. Just follow the instructions printed in the terminal as to how to generate the token and what to do with it.

**Accessing The Application**

_In the development environment:_

In the development environment the clinikal client application is completely outside of the container and communicates with the server-side inside the container.

Go to HOST_CODEBASE_PATH/INSTALLATION_NAME/clinikal-react and run npm start.

To directly access the api or the  community’s openemr frontend, use localhost:OPENEMR_PORT.

_In the test environment:_

To access the clinikal client application, use DOMAIN_NAME.

To access the api or the  community’s openemr frontend, use backend.DOMAIN_NAME (e.g. backend.whatever.com).


This project is sponsored by the Israeli Ministry Of Health.
