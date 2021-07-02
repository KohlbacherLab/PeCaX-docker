#!/bin/bash

# Default volume name should be prefixed with folder name
default_volume_prefix="$(echo ${PWD##*/} | tr '[A-Z]' '[a-z]')"

function show_usage() {
  echo "Usage: "
  echo "${0} -h | -b | -i | -a | -r | -p {argument}"
  echo "Details:"
  echo "This script is used to either setup the SBML4J volumes, setup the database from database dumps, or backup the databases into a database dump."
  echo "You can either use any one option alone, or use the -i and -r options together."
  echo "  -h : Print this help"
  echo "  -b {argument} :"
  echo "     Backup the current database into the backup files named by the {argument}"
  echo "  -i :"
  echo "     Install prerequisits for SBML4J."
  echo "     This will recreate the volumes used for SBML4J and the (empty) neo4j database."
  echo "  -r {argument} :"
  echo "     Restore the neo4j database from the database dumps in the files with prefix given by the {argument}"
  echo "  -p {argument} :"
  echo "     Use {argument} as prefix for the volumes created, i.e. argument_sbml4j_service_vol"
  echo "     Use in conjuction with the -b, -i, -r flags."
  echo " "
  echo "Examples:"
  echo "${0} -i :"
  echo "   This will (re)-create the volumes for SBML4J and use the default api definition file ${default_api_def} as source for the api page"
  echo "${0} -b mydbbackup"
  echo "   This will create a database dump of the neo4j and system database in the files mydbbackup-neo4j.dump and mydbbackup-system.dump respectively"
  echo "${0} -r mydbbackup"
  echo "   This will resore a database dump from the neo4j and system database dump files mydbbackup-neo4j.dump and mydbbackup-system.dump."
  echo "   WARNING: Any data currently stored in the database will be overwritten"
  echo "${0} -i -r mydbbackup"
  echo "   This will (re-)create the volumes for SBML4J (as described above) and load the database backup from the database dunmp files as described above."
  echo "${0} -i -r mydbbackup -p my-compose"
  echo "   This will (re-)create the volumes with names my-compose_sbml4j_neo4j_vol instead of the default name ${default_volume_prefix}_sbml4j_neo4j_vol (derived from the current directory) for SBML4J (as described above) and load the database backup from the database dunmp files as described above."
  echo "   This needs to be used when you want to use these volumes in a different compose setup"
}

function install() {
    prefix_name=$1
    # Steps to do:
    # Start a docker container running a shell
    # mount the /vol dir to create all prerequisits for neo4j
    # run script inside container that
    #	creates plugin dir
    #   downloads apoc plugin
    #   creates logs dir
    #   creates data dir
    #   creates conf dir
    #   copies conf file in volume
    #   fixes permissions
    echo "Creating volume for neo4j database"
    docker run --rm --detach --mount type=bind,src=${PWD}/scripts,dst=/scripts --mount type=bind,src=${PWD}/conf,dst=/conf --mount type=volume,src=${prefix_name}_sbml4j_neo4j_vol,dst=/vol alpine /scripts/setup_neo4j.sh
    # Start a docker container running a shell
    # mount the /sbml4j dir to create all prerequisits for sbml4j
    # basically create the logs folder in the volume
    echo "Creating volume for the sbml4j service"
    docker run --rm --detach --mount type=volume,src=${prefix_name}_sbml4j_service_vol,dst=/logs alpine touch /logs/root.log
}

function ensure_db_backups_folder_exists() {
    if [ ! -d "${PWD}/db_backups" ]
      then
        echo "Directory for database backups not found. Creating directory with name 'db_backups' in current folder ${PWD}"
        mkdir -p ${PWD}/db_backups
    fi
}

function setup_db() {
    backup_base_name=$1
    prefix_name=$2
    ensure_db_backups_folder_exists
    # Start neo4j for restoring the neo4j backup (twice: one neo4j, one system)
    docker run --interactive --tty --rm --publish=7474:7474 --publish=7687:7687 --mount type=volume,src=${prefix_name}_sbml4j_neo4j_vol,dst=/vol --mount type=bind,src=$PWD/db_backups,dst=/backups --user="7474:7474" --env NEO4J_CONF=/vol/conf neo4j:4.1.6 neo4j-admin load --from=/backups/${backup_base_name}-neo4j.dump --database=neo4j --force    
# 
    docker run --interactive --tty --rm --publish=7474:7474 --publish=7687:7687 --mount type=volume,src=${prefix_name}_sbml4j_neo4j_vol,dst=/vol --mount type=bind,src=$PWD/db_backups,dst=/backups --user="7474:7474" --env NEO4J_CONF=/vol/conf neo4j:4.1.6 neo4j-admin load --from=/backups/${backup_base_name}-system.dump --database=system --force    

}

function backup_db() {
    backup_base_name=$1
    prefix_name=$2
    ensure_db_backups_folder_exists
    # Start neo4j for backing upthe neo4j database (twice: one neo4j, one system)
    docker run --interactive --tty --rm --publish=7474:7474 --publish=7687:7687 --mount type=volume,src=${prefix_name}_sbml4j_neo4j_vol,dst=/vol --mount type=bind,src=$PWD/db_backups,dst=/backups --user="7474:7474" --env NEO4J_CONF=/vol/conf neo4j:4.1.6 neo4j-admin dump --database=neo4j --to=/backups/${backup_base_name}-neo4j.dump 

    docker run --interactive --tty --rm --publish=7474:7474 --publish=7687:7687 --mount type=volume,src=${prefix_name}_sbml4j_neo4j_vol,dst=/vol --mount type=bind,src=$PWD/db_backups,dst=/backups --user="7474:7474" --env NEO4J_CONF=/vol/conf neo4j:4.1.6 neo4j-admin dump --database=system --to=/backups/${backup_base_name}-system.dump 
}

declare -i i=0

while getopts hb:ir:p: flag
do
   case "${flag}" in
       h) show_usage
          exit 0
          ;;
       b) backup_name=${OPTARG}
          do_backup=True
          i=i+100
          #echo "Performing database backup into file: $backup_name"
          ;;
       i) do_install=True
          i=i+1
          ;;
       r) backup_name=${OPTARG}
          do_setup=True
          #echo "Performing database setup from file: $backup_name"
          i=i+10
          ;;
       p) prefix_name=${OPTARG}
          is_prefix_set=True
          ;;
   esac
done

echo $i


function check_prefix_name() {
  # Do we have a custom prefix set
  if [ "$is_prefix_set" = True ]
    then
      echo "Using custom prefix name ${prefix_name}"
    else
      echo "Using default prefix name ${default_volume_prefix}"
      prefix_name=$default_volume_prefix
  fi
}

if [ "$i" -lt "1" ]
   then
     echo "No argument given. Please give one or two arguments."
     show_usage
     exit 0
elif [ "$i" -lt "10" ]
   then
     echo "Performing installation of prerequisits for running sbml4j."
     check_prefix_name
     install $prefix_name
     echo "Successfully installed prerequisists for running sbml4j."
     exit 0
elif [ "$i" -lt "11" ]
   then
     echo "Restoring database from dumps: $backup_name-neo4j.dump and $backup_name-system.dump."
     check_prefix_name  
     setup_db $backup_name $prefix_name
     echo "Successfully restored database."
     exit 0
elif [ "$i" -lt "12" ]
   then
     echo "Performing installation of prerequisits for running sbml4j."
     check_prefix_name
     install $prefix_name
     echo "Restoring database from dumps: $backup_name-neo4j.dump and $backup_name-system.dump."
     setup_db $backup_name $prefix_name
     echo "Successfully installed prerequisits and resored database state."
     exit 0
elif [ "$i" -lt "101" ]
   then
     echo "Performing database backup into dump-files $backup_name-neo4j.dump and $backup_name-system.dump."
     check_prefix_name
     backup_db $backup_name $prefix_name
     echo "Successfully created database backup into dumps: $backup_name-neo4j.dump and $backup_name-system.dump." 
     exit 0
fi
         

