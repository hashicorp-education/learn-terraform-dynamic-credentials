## Introduction

Terraform Cloud's Dynamic Provider Credentials allow you to configure Terraform
Cloud to authenticate with your cloud provider by creating a trust relationship
between Terraform Cloud and your cloud provider. When you plan or apply changes
through Terraform Cloud with dynamic credentials configured, Terraform Cloud
will provide information about the identity of the workload being handled to
your cloud provider, in the form of a Terraform Workload Identity (TWI) token.
Your cloud provider will then respond with temporary credentials which Terraform
Cloud will use to provision your resources for the current workflow step.

Dynamic Provider Credentials give you fine-grained control over the access each
of your organization's projects gets to your cloud provider environments by
ensuring that the workload and lifecycle step match those you configure in the
trust relationship. They also limit the blast radius of compromised credentials
by ensuring that authentication requests are signed by Terraform Cloud or your
Terraform Enterprise instance. This workflow is built on the OpenID Connect
protocol, an open source standard for verifying identity across different
systems.

In this tutorial, you will set up a trust relationship between Terraform Cloud
and your cloud provider and configure a workspace with dynamic credentials. Then
you will provision infrastructure for that workspace, allowing Terraform Cloud
to authenticate the request using that trust relationship and dynamic
credentials.

### Configuring Trust with your Cloud Platform

In this tutorial, you will configure the integration by following these two
steps:

1. Configure your cloud provider: Set up a trust configuration between your
   cloud provider and Terraform Cloud. You will also create the roles and
   policies to define which infrastructure your dynamic credentials will provide
   access to.
1. Configure Terraform Cloud: Add the required environment variables to the
   Terraform Cloud workspace which will use Dynamic Credentials to provision your infrastructure.

Once you create the trust relationship and configure your workspace, Terraform
Cloud will automatically authenticate to your cloud provider each time you
perform an action such as a plan or apply. The provider authentication is valid
for the length of the action.

## Prerequisites

This tutorial assumes that you are familiar with the Terraform and Terraform
Cloud workflows. If you are new to Terraform, complete the [Get Started
collection](/collections/terraform/aws-get-started) first. If you are new to
Terraform Cloud, complete the [Terraform Cl oud Get Started
tutorials](/collections/terraform/cloud-get-started) first.

For this tutorial, you will need:

- Terraform v1.2+ installed locally.
- a [Terraform Cloud
  account](https://app.terraform.io/signup/account?utm_source=learn) and
  organization.
- Terraform Cloud [locally authenticated](/tutorials/terraform/cloud-login).
- An account with your cloud provier, with local credentials configured for use
  with Terraform.

## Fork example repository

Fork the [example repository]() into your GitHub account.

## Clone example repository

```sh
$ git clone ...
```

Change into the example repository directory.

```sh
$ cd learn-terraform-dynamic-credentials
```

Change into the appropriate subdirectory for your cloud provider.

<Tabs>
  <Tab heading="AWS" group="aws">

```sh
$ cd aws
```

  </Tab>
  <Tab heading="Azure" group="azure">
  </Tab>
  <Tab heading="GCP" group="gcp">
  </Tab>
  <Tab heading="Vault" group="vault">
  </Tab>
</Tabs>

## Create trust relationship

The example repository contains Terraform configuration which you will use to
create the trust relationship. In this tutorial, you will create the trust
relationship by running Terraform commands locally. In production, you may
prefer to manage your trust relationships in their own Terraform Cloud
workspaces. In many organizations, these relationships will be managed by a
seperate role or team from those that manage your application infrastructure.
For example, some organizations centralize permissions management into a
security operations team which configures and manages the workspaces for your
trust relationships, while individual application teams configure and manage the
workspaces for their infrastructure to use the dynamic credentials enabled by
those trust relationships.

Change into the directory which contains the configuration for the trust
relationship.

```sh
$ cd trust
```

### Review trust relationship configuration

Open `main.tf` and review the configuration for your trust relationship.

First, the configuraton sets your AWS region, and retrieves the TLS certificate
for Terraform Cloud.

<CodeBlockConfig filename="main.tf" hideClipboard>

```hcl
provider "aws" {
  region = var.aws_region
}

data "tls_certificate" "tfc_certificate" {
  url = "https://${var.tfc_hostname}"
}
```

</CodeBlockConfig>

AWS will use this TLS certificate to verify that requests for credentials come
from Terraform Cloud or your Terraform Enterprise instance.

Next, the configuration sets up the OpenID Connect provider with the TLS
certificate, an audience specific to AWS, and the SHA1 fingerprint from the
certificate.

<CodeBlockConfig filename="main.tf" hideClipboard>

```hcl
resource "aws_iam_openid_connect_provider" "tfc_provider" {
  url             = data.tls_certificate.tfc_certificate.url
  client_id_list  = [var.tfc_aws_audience]
  thumbprint_list = [data.tls_certificate.tfc_certificate.certificates[0].sha1_fingerprint]
}
```

</CodeBlockConfig>

~> Note: The term `provider` in this configuration refers to the hostmane of the
AWS server which implements the OpenID Connect standard that Terraform Cloud
uses to generate dynamic credentials.

Next, the configuration defines an IAM role for the trust relationship.

<CodeBlockConfig filename="main.tf" hideClipboard>

```hcl
resource "aws_iam_role" "tfc_role" {
  name = "tfc-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Principal": {
       "Federated": "${aws_iam_openid_connect_provider.tfc_provider.arn}"
     },
     "Action": "sts:AssumeRoleWithWebIdentity",
     "Condition": {
       "StringEquals": {
         "app.terraform.io:aud": "${one(aws_iam_openid_connect_provider.tfc_provider.client_id_list)}"
       },
       "StringLike": {
         "app.terraform.io:sub": [
           "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:*"
         ]
       }
     }
   }
 ]
}
EOF
}
```

</CodeBlockConfig>

This role defines the OpenID claims for your trust relationship. These claims
define the conditions AWS will use to validate the content of the TWI token that
Terraform Cloud will provide when it requests dynamic credentials. AWS will
respond to requests that match these claims with a set of dynamic credentials
that grant access to this role. Terraform Cloud will then use those dynamic
credentials to provision your resources.

For this tutorial your token will match the following claims:

- `aud`: The audience of the token, usually the cloud provider which provides
  the infrastructure you will manage with Terraform Cloud. This ensures that,
  for example, a workload identity token intended for AWS will not be considered
  valid to authenticate with Vault.

- `sub`: The subject of the token, which includes your Terraform Cloud
  organization name, as well as the projects and workspaces that can use this
  trust relationship. This ensures that your cloud provider will only
  authenticate requests under this trust relationship for the specified projects
  and workspaces in your organization, and allows you to scope permissions on a
  per-project or per-workspace basis.

~> **Note**: Refer to the [Dynamic Credentials documentation](FIXME: Add link)
for a list of other possible claims.

The `sub` claim for Terraform Cloud includes four parts:

- `organization:${var.tfc_organization_name}`: Your Terraform Cloud organization name.
- `project:${var.tfc_project_name}`: The project name.
- `workspace:workspace:${var.tfc_workspace_name}`: The workspace name.
- `run_phase:*`: The workflow phase being performed, such as a plan or an apply.

The example configuration uses the wildcard character (`*`) to allow any
workflow phase. When you define your trust relationships, you can also use `*`
to allow requests from any project or workspace, or include multiple subjects in
the `app.terraform.io:sub` list to allow multiple named projects and workspaces
to use this trust relationship.

Finally, the configuration defines the IAM policy that will control which
resources your dynamic credentials will have access to, and attaches that policy
to your role.

<CodeBlockConfig filename="main.tf" hideClipboard>

```hcl
resource "aws_iam_policy" "tfc_policy" {
  name        = "tfc-policy"
  description = "TFC run policy"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "ec2:*"
     ],
     "Resource": "*"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tfc_policy_attachment" {
  role       = aws_iam_role.tfc_role.name
  policy_arn = aws_iam_policy.tfc_policy.arn
}
```

</CodeBlockConfig>

This policy allows access to manage EC2 isntances, which you will provision in
the next section. You can configure the policies attached to your trust
relationships to be as restrictive or permissive as you need. Bear in mind that
if seperate teams within your organization manage your trust relationships and
your application infrastructure, you will need to coordinate change requests
between those teams in order to manage these policies.

### Configure organization and workspace name

```sh
$ cp terraform.tfvars.example terraform.tfvars
```

Open `terraform.tfvars` and set your organization and workspace name.

```hcl
tfc_organization_name = "<YOUR_ORG>"
tfc_workspace_name    = "dynamic-credentials-example-infrastructure"
```

Replace `<YOUR_ORG>` with your Terraform cloud organization name. Use the given workspace name for this tutorial.

### Apply configuration

Apply this configuration to create your trust relationship. Respond to the confirmation prompt with a `yes`.

```sh
$ terraform apply
data.tls_certificate.tfc_certificate: Reading...
data.tls_certificate.tfc_certificate: Read complete after 0s [id=896bd9f2e4b99335cca9e93921664e636e35cab3]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_openid_connect_provider.tfc_provider will be created
  + resource "aws_iam_openid_connect_provider" "tfc_provider" {
##...
Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + role_arn = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_iam_policy.tfc_policy: Creating...
aws_iam_openid_connect_provider.tfc_provider: Creating...
aws_iam_openid_connect_provider.tfc_provider: Creation complete after 0s [id=arn:aws:iam::841397984957:oidc-provider/app.terraform.io]
aws_iam_role.tfc_role: Creating...
aws_iam_policy.tfc_policy: Creation complete after 0s [id=arn:aws:iam::841397984957:policy/tfc-policy]
aws_iam_role.tfc_role: Creation complete after 1s [id=tfc-role]
aws_iam_role_policy_attachment.tfc_policy_attachment: Creating...
aws_iam_role_policy_attachment.tfc_policy_attachment: Creation complete after 0s [id=tfc-role-20230118171909964800000001]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

role_arn = "arn:aws:iam::841397984957:role/tfc-role"
```

You will use the `role_arn` output value in the next section.

Now that you have created the trust relationship, Terraform cloud will be able
to request dynamic credentials when it provisions infrastructure for the `dynamic-credentials-example-infrastructure` workspace.

## Provision infrastructure with dynamic credentials

Use your trust relationship to provision infrastructure in Terraform Cloud.
First, move to the `infra` directory and review the example configuration.

```sh
cd ../infra
```

This configuration provisions a single EC2 instance in the `us-east-2` region.

<CodeBlockConfig filename="main.tf" hideClipboard>

```hcl
provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<html><body><div>Hello, world!</div></body></html>" > /var/www/html/index.html
    EOF

  tags = var.tags
}
```

</CodeBlockConfig>

### Create infrastructure workspace

Now, navigate to [Terraform Cloud](https://app.terraform.io) in your web
browser, and select the organization you are using for this tutorial.

Create a new workspace in your default project by selecting **New > Workspace**
on the **Projects & workspaces** page. Configure it with the following settings.

1. Select **Version control workflow**.
1. Choose the `learn-terraform-dynamic-credentials` GitHub repository that you forked earlier in this tutorial.
  - If you have not yet connected your GitHub account to Terraform Cloud, follow the prompts to do so.
1. On the **Configure settings** step, expand the **Advanced options** interface, and set the **Terraform Working Directory** to `aws/infra`.
1. Leave the rest of the settings on the **Configure settings** step at their default values, then click **Create Workspace**.

### Configure trust variables

After you create your workspace, navigate to its **Variables** page and add the
following workspace variables:

| Variable category | Key | Value | Sensitive |
+-------------------+-----+-------+-----------+
| Environment variable | TFC_AWS_PROVIDER_AUTH | true | No |
| Environment variable | TFC_AWS_RUN_ROLE_ARN | <ROLE_ARN> | No |

Replace `<ROLE_ARN>` with the `role_arn` output value from the previous step, without the quotation marks (`"`).

~> **Tip**: If you closed the terminal window with the output of the `terraform
  apply` command from the last section, return to the `trust` directory and run
  `terraform output` to have Terraform print it out again.

### Apply configuration

## Clean up your infrastructure

### Destroy infrastructure

### Delete Infrastructure workspace

### Destroy trust relationship

## Next steps

