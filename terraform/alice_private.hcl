provider "openstack" {
  user_name   = "example-user"
  tenant_name = "example-project"
  password    = "example-password"
  auth_url    = "https://openstack-auth-url:5000/v3"
  region      = "RegionOne"
}

# 네트워크 및 서브넷 설정
resource "openstack_networking_network_v2" "network" {
  name           = "private_network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "private_subnet"
  network_id = openstack_networking_network_v2.network.id
  cidr       = "10.0.0.0/24"
  ip_version = 4
}

# 라우터 및 라우터 인터페이스 설정
resource "openstack_networking_router_v2" "router" {
  name             = "router"
  admin_state_up   = true
  external_network = "your-external-network-id"
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

# 보안 그룹 및 규칙 설정
resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "secgroup"
  description = "Security group for allowing HTTP and SSH access"
}

resource "openstack_networking_secgroup_rule_v2" "http_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "ssh_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# 가상 머신 인스턴스 설정
resource "openstack_compute_instance_v2" "master" {
  name            = "master-node"
  image_name      = "ubuntu-20.04"
  flavor_name     = "m1.medium"
  key_pair        = "your-ssh-key-name"
  security_groups = [openstack_networking_secgroup_v2.secgroup.name]

  network {
    uuid = openstack_networking_network_v2.network.id
  }
}

resource "openstack_compute_instance_v2" "worker" {
  count           = 2
  name            = "worker-node-${count.index}"
  image_name      = "ubuntu-20.04"
  flavor_name     = "m1.medium"
  key_pair        = "your-ssh-key-name"
  security_groups = [openstack_networking_secgroup_v2.secgroup.name]

  network {
    uuid = openstack_networking_network_v2.network.id
  }
}

# MinIO 스토리지 구성 (예시적 접근)
module "minio" {
  source = "github.com/minio/minio-terraform"

  # 클러스터 구성에 필요한 설정
  servers           = 4
  volumes_per_server = 4
  volume_size       = 10
}

