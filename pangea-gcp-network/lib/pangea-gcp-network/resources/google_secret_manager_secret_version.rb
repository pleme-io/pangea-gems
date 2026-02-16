def google_secret_manager_secret_version(name:, secret:, secret_data:, virtual: nil)
  virtual_name = virtual || name
  resource :google_secret_manager_secret_version, virtual_name do
    secret      secret
    secret_data secret_data
  end
  { id: "${google_secret_manager_secret_version.#{virtual_name}.id}" }
end