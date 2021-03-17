# PeCaX
Personalized Cancer and Network Explorer (PeCaX) is a tool for identifying patient specific cancer mechanisms by providing a complete mutational profile from variants to networks. It employs ClinVAP to perform clinical variant annotation which focuses on processing, filtering and prioritization of the variants to find the disrupted genes that are involved in carcinogenesis and to identify actionable variants from the mutational landscape of a patient. In addition it creates networks showing the connections between the driver genes and the genes in their neighbourhood and automatically performs pathway enrichment analysis using pathway resources (SBML4j). Its interactive visualisation (BioGraphVisart) supports easy network exploration and patient similarity (node overlap) and a merged network graph of two patient-specific networks can be calculated.

Please refer this document for implementation of the application. Documentation of the pipeline is available at [Wiki page](https://github.com/MirjamFi/PeCaX/wiki).

## Usage with Docker
Requirements: Docker Engine release 1.13.0+, Compose release 1.10.0+.

Please make sure that you have 34 GB of physical empty space on your Docker Disk Image, and ports 3030, 3000, 8529, 7474, 7687, 8080 are not being used by another application.

To run the pipeline for the first time, please follow the steps given below.

1. Clone the Git repository via:

    `git clone https://github.com/MirjamFi/PeCaX.git`

2. For human genome assembly GRCh37, use: 

    `docker-compose up vep_files_GRCh37`

    If your analysis requires GRCh38, use: 
    
    `docker-compose up vep_files_GRCh37`

3. Start PeCaX services via

    `docker-compose up db_setup`

    `docker-compose up apoc_install`

    `docker-compose up pecax`

## Next time:

    docker-compose up pecax

## Exit:

    Ctrl+c

    docker-compose down

## In Browser of your choice open localhost:3030

### We recommend using full screen to enjoy the full experience.


## Information about docker volumes

PeCaX uses several volumes to store data and work files. They are briefly described here:

- sbml4j_network_db: used to store the knowledge graph and created networks.
- The local folders: ./neo4j/logs, ./neo4j/conf, ./neo4j/plugins are mapped into the sbml4jdb container
- The local folder ./sbml4j/logs is mapped into the sbml4j container
- The local folder ./database_backups is mapped into the temporary containers "db_setup" and "db_backup" to facilitate database creation form a tar.gz and database backup to the tar.gz respectively
- arangodb_data_container: database directory to store the collection data (username, jobid, json, network uuids)
- arangodb_apps_data_container: apps directory to store any extensions

## Create a network database backup

The networks are stored in a docker volume and are thus persisted between individual PeCaX sessions.
If you however delete or prune your docker volumes, the created network volume will be deleted and you will have to rerun

	docker-compose up db_setup

For your previous networks to be available after a prune or delete of the volumes you have to save a backup of the network database.
You can do this with

	docker-compose up db_backup

Be advised that this will overwrite the initial *clean* database that shipped with PeCaX.
If you want to keep both, you will have to rename the default database backup before creating the backup, for example with:

	cd database_backups && cp sbml4j_pecax_0.0.32.tar.gz sbml4j_pecax_0.0.32_initial.tar.gz

To revert back to the initial database, simply rename the file back to its original name with;

	cd database_backups && cp sbml4j_pecax_0.0.32_initial.tar.gz sbml4j_pecax_0.0.32.tar.gz
