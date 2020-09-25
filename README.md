Infrastructure as Code
=========

##### You will need

- **[Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)**: Instalation guide

- **[Packer](https://learn.hashicorp.com/tutorials/packer/getting-started-install)**: Instalation guide


Our nginx server image has created by server.json

### Image creation
Sensive data like credentials can be defined at your **env**, we need 
**ARM_CLIENT_ID**
**ARM_CLIENT_SECRET**
**ARM_SUBSCRIPTION_ID**

```
"client_id": "{{env `ARM_CLIENT_ID`}}",
"client_secret": "{{env `ARM_CLIENT_SECRET`}}",
"subscription_id": "{{env `ARM_SUBSCRIPTION_ID`}}"
```

it can be set using 
```
export ARM_CLIENT_ID=<ARM_CLIENT_ID_HERE>
export ARM_CLIENT_SECRET=<ARM_CLIENT_SECRET>
export ARM_SUBSCRIPTION_ID=<ARM_SUBSCRIPTION_ID>
```

Run packer and build our image.

```
packer build server.json
```

#### Instance deploy

```
terraform plan -out solution.plan
terraform apply solution.plan
```

#### Variables
Variables can be filled using 

```
terraform apply solution.plan -var prefix="simple_nginx_vm"
```


Environment variables for terraform .tf files can be added to the file var.tf 



## License
[Mozilla Public License v2.0](https://github.com/hashicorp/terraform/blob/master/LICENSE)