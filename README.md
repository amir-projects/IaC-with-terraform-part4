# Terraform Advanced Concepts

Welcome to this Terraform session where we’ll explore more advanced concepts including **Provisioners**, **Workspaces**, and **Modules**. We’ll also walk through a **Hands-on Lab** to reinforce learning with practical examples.

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

Provisioners are used to execute scripts or commands on a local or remote machine as part of resource creation or destruction.

### ✅ Use Cases:
- Bootstrapping instances
- Installing dependencies
- Configuration tasks post-provisioning

### 🧪 Example: Using `remote-exec` on an EC2 instance

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
⚠️ Provisioners are a last resort — prefer using user-data or configuration management tools when possible.

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

## 💡 Example Use Case

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
## 🧪 Using `terraform.workspace` in Code

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