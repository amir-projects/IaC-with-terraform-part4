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
⚠️ Provisioners are a last resort — prefer using user-data or configuration management tools when possible.