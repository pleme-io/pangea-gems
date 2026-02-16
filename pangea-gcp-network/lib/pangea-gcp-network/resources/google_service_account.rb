def google_service_account(name:, account_id:, display_name:)
  resource :google_service_account, name do
    account_id   account_id
    display_name display_name
  end
  { name: "${google_service_account.#{name}.name}", email: "${google_service_account.#{name}.email}" }
end