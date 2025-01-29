# artitfacthub-catalog-poc

Contains artifacthub installation and sample backstage plugins

## prerequistes

- Install oc and helm cli

## Installation

- clone the repo `git clone https://github.com/karthikjeeyar/artitfacthub-catalog-poc`
- login to the openshift cluster
- run `make all` to install artifacthub in openshift cluster.
- click on the artifacthub route from the output in the cli.

To add backstage plugins in the catalog:

- login to the artifacthub with default username & password. The credentials for the demo user are: demo@artifacthub.io / changeme. You can change the password from the control panel once you log in.
- click on the profile icon on the top right and go to the control panel to add a new repository

- Choose the kind as Backstage plugins and fill the details as shown below
  [!image](./images/add-backstage-plugin.png)
- After adding the repository, run `make start_tracker` command to install the plugins into artifacthub.
- You can now browse the packages using the search bar
  [!image](./images/searchbar.png)

  [!image](./images/tekton.png)
