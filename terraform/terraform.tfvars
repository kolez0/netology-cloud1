vms_resources = {
  nat_instance = {
    cores         = 2
    memory        = 2
    core_fraction = 20
    disk_size     = 5
    nat           = true
  },
  public_vm = {
    cores         = 2
    memory        = 2
    core_fraction = 20
    disk_size     = 8
    nat           = true
  },
  private_vm = {
    cores         = 2
    memory        = 2
    core_fraction = 20
    disk_size     = 8
    nat           = false
  }
}
