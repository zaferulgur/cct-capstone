# cct-capstone
# Terraform Scripts of the ZU-EKS
Managing the all infrastructure resources of the Zafer Ulgur's project via Terraform with applying the Infrastructure as Code mindset (IaC)

> Please read the [Terraform-Guide](#Terraform-Guide) section before to go work on that repo!
<br/>


## How to work on this Terraform scripts repo?
1. Go to the `eks` directory to manage all env based resources;
```sh
    cd ./eks
    export AWS_PROFILE="zu-terraform"
```

2. Initialize the `backend`, `modules` and `provider plugins`;
```sh
    # terraform init -backend-config="access_key=<your access key>" -backend-config="secret_key=<your secret key>"
    terraform init
```

3. List the all workspaces(using the env based workspace structure);
```sh
    terraform workspace new zu-eks

    terraform workspace list
```

4. Select the `zu-eks` workspace to work on ZU-EKS PoC environment resources;
```sh
    terraform workspace select zu-eks
```

5. Show the current workspace to confirm that working on the correct workspace;
```sh
    terraform workspace show
```

6. Validate the syntax of terraform files;
```sh
    terraform validate
```

7. Generate execution plan to see what changed before to run apply(deploy) the new changes;
```sh
    terraform plan
```

8. Execute/Deploy the actions proposed in terraform plan created at previous step;
```sh
    terraform apply
```
<br/>
