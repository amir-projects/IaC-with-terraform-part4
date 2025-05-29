# Terraform Advanced Concepts

This repository is designed to help you explore and master advanced Terraform concepts such as **Provisioners**, **Workspaces**, and **Modules**, with hands-on labs that demonstrate real-world use cases. Whether you're looking to improve your Infrastructure-as-Code skills or build scalable, production-ready infrastructure, this repo provides practical examples and clear explanations to support your learning journey.

## 📅 Agenda

- Terraform Provisioners
- Terraform Workspaces
- Terraform Modules
- Hands-on Lab

## 📦 Prerequisites

- Terraform installed (Latest Version Preferred)
- AWS CLI installed & configured
- Git and code editor (VS Code preferred)

---

## 1️⃣ Terraform Provisioners

Terraform is primarily designed to manage infrastructure resources **declaratively**. However, there are times when you need to perform **imperative actions**, such as running setup scripts or configuring software on newly created resources.

This is where **provisioners** come in.



### 🧰 What Are Provisioners?

Provisioners allow you to execute **arbitrary scripts or commands** during the creation or destruction of a resource. They are typically used for tasks like bootstrapping and configuring software — actions that can't be fully managed through Terraform's native resource model.

### ⚙️ When Do Provisioners Run?

- **Create-time**: After a resource has been successfully created.
- **Destroy-time**: Before a resource is destroyed (also known as a "destroy provisioner").

> 💥 **Important Behavior:**  
> If a `create-time` provisioner fails, Terraform will mark the resource as **tainted**, meaning it will be destroyed and recreated during the next `terraform apply`.


### ✅ Common Use Cases:
- Bootstrapping virtual machines or containers
- Installing dependencies or updates
- Running configuration tasks post-provisioning
- Cleanup operations before resource deletion

> ⚠️ **Important:**  
> Provisioners are not a replacement for proper infrastructure automation.  
> Prefer using **user data**, **cloud-init**, or **configuration management tools** (like Ansible or Puppet) when possible.

### 🔧 Types of Provisioners

Terraform supports several built-in provisioners. The most commonly used ones include:

| Provisioner     | Purpose |
|------------------|---------|
| `remote-exec`    | Executes commands on the target machine via SSH or WinRM |
| `local-exec`     | Runs commands locally on the machine running Terraform |
| `file`           | Uploads files or directories to the remote machine |

In this guide, we'll focus on `remote-exec` and `local-exec`.

### 🖥 `remote-exec`

The `remote-exec` provisioner runs commands **on the target machine**, typically via SSH or WinRM.  
Use it when you need to:
- Install software or dependencies on the remote instance
- Run configuration scripts post-provisioning
- Perform setup steps not handled by cloud-init or user data

Example: Using `remote-exec` on an EC2 instance

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}
```
### 🖥 `local-exec`

The `local-exec` provisioner runs a command on the **machine where Terraform is executed**.  
This is useful for tasks like:
- Logging output or resource details
- Triggering external scripts or notifications (e.g., sending a message to Slack)
- Creating or modifying local files based on created resources

Example: Using `local-exec` to Run Commands Locally

The `local-exec` provisioner runs commands on the **machine where Terraform is executed** — useful for logging, triggering external actions, or preparing files.

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo 'Instance IP: ${self.public_ip}' >> instance_ips.txt"
  }
}
```
---

## 2️⃣ Terraform Workspaces

Terraform Workspaces allow you to manage multiple state files for the same configuration. They are useful when deploying the same infrastructure to different environments (e.g., `dev`, `staging`, `prod`) without duplicating your code.

---

### 📘 What is a Workspace?

A workspace is an isolated instance of state data associated with a given set of Terraform configuration files. By default, Terraform operates in the `default` workspace.

When you create a new workspace, Terraform maintains a separate state file for that workspace, allowing you to deploy the same configuration independently across multiple environments.

---

### 🧠 Key Concepts

- Workspaces share the same configuration.
- Each workspace has its own separate state.
- Variables do **not** automatically change with workspaces.
- Use `terraform.workspace` to write logic based on the current workspace.

---

### 🔧 Common Commands

```bash
# List all workspaces
terraform workspace list

# Create a new workspace
terraform workspace new dev

# Switch to a workspace
terraform workspace select dev

# Show current workspace
terraform workspace show

# Delete a workspace
terraform workspace delete dev
```

### 💡 Example Use Case

You want to deploy the same EC2 instance in `dev` and `prod` environments, but with different instance types. Use **workspaces** to separate the state and **conditionally configure** resources.

---

### 🛠 Step 1: Add Conditional Logic in `main.tf`

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
}
```
### 🛠 Step 2: Create a terraform.tfvars File

Use separate variable files for different environments:

**`dev.tfvars`**

```hcl
instance_type = "t2.micro"
```
**`prod.tfvars`**

```hcl
instance_type = "t3.medium"
```

### 🛠 Step 3: Apply in Different Workspaces

Use Terraform workspaces to separate state for different environments and apply the configuration with corresponding variable files.

```bash
# Create and switch to the 'dev' workspace
terraform workspace new dev
terraform apply -var-file="dev.tfvars"

# Create and switch to the 'prod' workspace
terraform workspace new prod
terraform apply -var-file="prod.tfvars"
```
### 🧪 Using `terraform.workspace` in Code

You can dynamically configure values based on the current workspace using a conditional expression.

```hcl
variable "instance_type" {
  default = terraform.workspace == "prod" ? "t3.medium" : "t2.micro"
}
```
This allows a single configuration to adapt its behavior across environments like dev, staging, or prod.

### ⚠️ Things to Keep in Mind

- Workspaces only isolate **state**, not configurations or infrastructure components.
- Avoid relying on workspaces for strong environment separation in teams — consider using **separate backends** for each environment.
- Best used for **lightweight environments** like `dev` or `test` where minimal isolation is acceptable.
- Combine workspaces with **modules** and **variable files** for scalable and maintainable infrastructure design.

---

## 3️⃣ Terraform Modules

Terraform Modules help you organize and reuse infrastructure code by grouping related resources together. Modules allow you to avoid repetition, enforce best practices, and build scalable infrastructure.


### 📘 What is a Module?

A **module** is a container for multiple resources that are used together. Every Terraform configuration has at least one module — the **root module**. You can also create reusable **child modules** stored locally, in the Terraform Registry, or in a Git repository.


### 💡 Benefits of Using Modules

- 🔁 **Reusability**: Use the same logic across multiple projects or environments.
- 🛠 **Maintainability**: Make updates in one place.
- 📦 **Organization**: Separate infrastructure into logical components.
- 👥 **Collaboration**: Teams can develop, test, and version modules independently.

### 📁 Module Directory Structure
A module typically contains the following files:
```
module-name/
├── main.tf         # Resources and logic
├── variables.tf    # Input variable definitions
├── outputs.tf      # Output values
```

You can organize your project by placing reusable modules in a `modules/` directory and referencing them from your main configuration.

**Example:**

```
project-root/
├── main.tf
├── modules/
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```
### 🧩 Example: Using a Module in Your Configuration

Once you've defined or referenced a module, you can call it directly from your main Terraform configuration:

```hcl
module "ec2_instance" {
  source = "./modules/ec2"

  instance_type = "t2.micro"
  ami           = "ami-0c55b159cbfafe1f0"
  tags = {
    Name = "my-ec2-instance"
  }
}
```
This block instructs Terraform to use the module located at `./modules/ec2` and pass in the required input variables such as `instance_type`, `ami`, and `tags`.

### 🖥 Example: Using a Local EC2 Module

```hcl
# modules/ec2/variables.tf

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
}

variable "ami" {
  description = "The Amazon Machine Image ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the EC2 instance"
  type        = map(string)
}

# modules/ec2/main.tf

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
  tags          = var.tags
}
```

### 🌐 Example: Using a Module from Terraform Registry

Terraform Registry hosts many pre-built, production-grade modules that you can easily integrate into your infrastructure projects. You can reference these modules using the format:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
}
```
### 🧩 Best Practices for Working with Modules

To ensure your Terraform modules are maintainable, reusable, and production-ready, follow these best practices:

- ✅ **Modular Design**:  
  Keep each module focused on a single responsibility (e.g., networking, compute, storage). Avoid bundling unrelated resources.

- 🔁 **Reusability Over Duplication**:  
  Build generic, parameterized modules that can be reused across environments (dev/staging/prod) and projects.

- 📦 **Use Input Variables**:  
  Expose configuration options via input variables to allow customization without modifying the module internals.

- 🔐 **Validate Inputs**:  
  Use `validation` blocks and `default` values where appropriate to prevent misconfigurations.

  ```hcl
  variable "instance_type" {
    description = "The EC2 instance type"
    type        = string
    default     = "t2.micro"
    validation {
      condition     = contains(["t2.micro", "t2.small", "t3.medium"], var.instance_type)
      error_message = "Only specific instance types are allowed."
    }
  }
  ```
- 📁 **Version Your Modules** :
  When publishing modules (e.g., to Terraform Registry or private module repository), use semantic versioning to manage changes safely.