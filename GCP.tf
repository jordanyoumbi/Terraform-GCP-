provider "google" {
  region      = "${var.region}"
}
#Definition du reseau

resource "google_compute_network" "default" {
  name                    = ""
  auto_create_subnetworks = "false"
}
#Definition du sous-reseau à partir du reseau creer

resource "google_compute_subnetwork" "subnet1" {
  name          = "sousreseau"
  ip_cidr_range = "${var.ip_cidr_range}"
  network       = "${google_compute_network.default.self_link}"
}
#Definition des flux entrants http avec un tag 

resource "google_compute_firewall" "http" {
  name = "firewallconf1"
  network = "${google_compute_network.default.name}"
  target_tags = ["votre_choix"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports = ["80"]
  }
}
#Definition accès par SSH avec un tag 

resource "google_compute_firewall" "ssh" {
  name = "firewallconf2"
  network = "${google_compute_network.default.name}"
  target_tags = ["votre_choix"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports = ["22"]
  }
}

resource "google_compute_firewall" "internalvpc" {
  name = "firewallconf3"
  network = "${google_compute_network.default.name}"
  target_tags = ["votre_choix"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
#    ports = ["all"]
  }
}


#Creation de l'instance et installation d une appli

resource "google_compute_instance" "vm" {
  count = "${var.nombrevm}"
  name         = "mavm${count.index + 1}"
  machine_type = "n1-standard-1"
  tags = ["votre_choix"]
#  metadata_startup_script = "${file("")}"
  disk {
    image = "debian-cloud/debian-8"
  }

  zone = "europe-west1-b"
  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet1.name}"
    access_config {
      
    }
  }

}

#definition d'un output pour l adresse public

output "mavm_public_ip" {
  
  value =
    "${google_compute_instance.vm.network_interface.0.access_config.0.assigned_nat_ip}"
}
