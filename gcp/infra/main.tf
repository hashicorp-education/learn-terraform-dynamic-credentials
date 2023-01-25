provider "google" {
  project = var.gcp_project_id
  region  = "global"
}


resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = "fedora-cloud-36"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<html><body><div>Hello, world!</div></body></html>" > /var/www/html/index.html
    EOF

  tags = var.tags
}
