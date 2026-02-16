def google_service_account_key(name:, service_account_id:, private_key_type:)
  resource :google_service_account_key, name do
    service_account_id service_account_id
    private_key_type   private_key_type
  end
  { private_key: "${google_service_account_key.#{name}.private_key}" }
end