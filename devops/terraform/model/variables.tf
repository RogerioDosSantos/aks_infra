variable "location" {
  description = "Azure region to deploy resources."
  type        = string
  default     = "centralus"
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default = {
    project     = "n8n"
    environment = "development"
  }
}
