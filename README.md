# PeCaX
Personalized Cancer and Network Explorer (PeCax) is a tool for identifying patient specific cancer mechanisms by providing a complete mutational profile from variants to networks. It employs ClinVAP to perform clinical variant annotation which focuses on processing, filtering and prioritization of the variants to find the disrupted genes that are involved in carcinogenesis and to identify actionable variants from the mutational landscape of a patient. In addition it creates networks showing the connections between the driver genes and the genes in their neighbourhood and automatically performs pathway enrichment analysis using pathway resources (SBML4j). Its interactive visualisation (BioGraphVisart) supports easy network exploration and patient similarity (node overlap) and a merged network graph of two patient-specific networks can be calculated.

Please refer this document for implementation of the application. Documentation of the pipeline is available at [Wiki page](https://github.com/MirjamFi/PeCaX/wiki).
## Usage with Docker
Requirements: [Docker](https://www.docker.com/get-started) Engine release 1.13.0+.

Please make sure that you have 34 GB of physical empty space on your Docker Disk Image, and ports 3030, 3000, 8529, 7474, 7687, 8080 are not being used by another application.

To tun the pipeline, please follow the steps given below.

	git clone https://github.com/KohlbacherLab/PeCaX-docker.git
	
	cd PeCaX-docker

    docker-compose up db_setup
  
    docker-compose up apoc_install
  
    docker-compose up pecax

## Next time:

    docker-compose up pecax
  
## Exit:

    Ctrl+c
  
    docker-compose down
  
### Storing the network database::
  
    docker-compose up db_backup 
    
### In Browser of your choice open localhost:3030

### We recommend using full screen to enjoy the full experience.
