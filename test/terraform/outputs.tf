output "custom_name" {
  value       = var.custom_name
  description = "Outputs the custom name"
}

output "pet" {
  value       = resource.random_pet.test.id
  description = "Outputs the custom name"
}