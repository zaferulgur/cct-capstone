resource "aws_kms_key" "this" {
  description = "EKS Secret Encryption Key"
}
