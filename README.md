# PeCaX
## Initial start:
Download the repository. Then in the terminal:

	cd PeCaX-docker-dev

    docker-compose up db_setup
  
    docker-compose up apoc_install
  
    docker-compose up pecax

Open localhost:3030 in browser of your choice.

## Starting it the next time:

    docker-compose up pecax
  
Open localhost:3030 in browser of your choice.

## Exiting the application:
In the open terminal:

    Ctrl+c
  
    docker-compose down
    
Close the browser window to clear all data.
  
### Storing the network database:
The network database is not stored automatically. To store it, execute in the open terminal:
  
    docker-compose up db_backup 
