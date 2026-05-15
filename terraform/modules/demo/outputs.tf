output "nodes" {
  description = "имя ноды и её приватный ip, прописать в config бота"
  value = {
    for k, v in google_compute_instance.node :
    k => v.network_interface[0].network_ip
  }
}
