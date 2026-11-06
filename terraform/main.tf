resource "yandex_vpc_network" "netology_vpc" {
  name = var.netology_vpc
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.netology_vpc.id
  v4_cidr_blocks = var.netology_public_subnet
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.netology_vpc.id
  v4_cidr_blocks = var.netology_private_subnet
  route_table_id = yandex_vpc_route_table.nat_instance_route.id
}

resource "yandex_vpc_route_table" "nat_instance_route" {
  name       = "nat-instance-route"
  network_id = yandex_vpc_network.netology_vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_image_family
}


# ---------------- NAT instance ----------------
resource "yandex_compute_instance" "nat_instance" {
  name        = "nat-instance"
  hostname    = "nat-instance"
  platform_id = var.vm_platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vms_resources["nat_instance"].cores
    memory        = var.vms_resources["nat_instance"].memory
    core_fraction = var.vms_resources["nat_instance"].core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      size     = var.vms_resources["nat_instance"].disk_size
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat        = var.vms_resources["nat_instance"].nat
  }

  scheduling_policy {
    preemptible = var.vm_preemptible
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file(var.ssh_public_key_path)}"
  }
}

# ---------------- Public VM ----------------
resource "yandex_compute_instance" "public_vm" {
  name        = "public-vm"
  hostname    = "public-vm"
  platform_id = var.vm_platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vms_resources["public_vm"].cores
    memory        = var.vms_resources["public_vm"].memory
    core_fraction = var.vms_resources["public_vm"].core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.vms_resources["public_vm"].disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = var.vms_resources["public_vm"].nat
  }

  scheduling_policy {
    preemptible = var.vm_preemptible
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file(var.ssh_public_key_path)}"
  }

  provisioner "file" {
    source      = pathexpand(var.ssh_private_key_path)
    destination = "/home/${var.vm_user}/.ssh/id_ed25519"

    connection {
      type        = "ssh"
      user        = var.vm_user
      private_key = file(pathexpand(var.ssh_private_key_path))
      host        = self.network_interface[0].nat_ip_address
      timeout     = "10m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.vm_user}/.ssh",
      "chmod 700 /home/${var.vm_user}/.ssh",
      "chmod 600 /home/${var.vm_user}/.ssh/id_ed25519",
    ]

    connection {
      type        = "ssh"
      user        = var.vm_user
      private_key = file(pathexpand(var.ssh_private_key_path))
      host        = self.network_interface[0].nat_ip_address
      timeout     = "10m"
    }
  }
}

# ---------------- Private VM ----------------
resource "yandex_compute_instance" "private_vm" {
  name        = "private-vm"
  hostname    = "private-vm"
  platform_id = var.vm_platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vms_resources["private_vm"].cores
    memory        = var.vms_resources["private_vm"].memory
    core_fraction = var.vms_resources["private_vm"].core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.vms_resources["private_vm"].disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.private.id
    nat        = var.vms_resources["private_vm"].nat
  }

  scheduling_policy {
    preemptible = var.vm_preemptible
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file(var.ssh_public_key_path)}"
  }
}