# data "template_file" "cloudinit" {
#     template = file("${path.module}/templates/userdata.yaml")

#     vars = {

#     }

# }

data "cloudinit_config" "cloudinit" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    filename     = "cloud.conf"
    content      = file("${path.module}/templates/userdata.yaml")
  }

}
