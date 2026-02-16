def google_secret_manager_secret(name:, secret_id:, replication:, virtual: nil)
  virtual_name = virtual || name
  resource :google_secret_manager_secret, virtual_name do
    secret_id secret_id
    replication do
      user_managed do
        replicas(replication[:user_managed][:replicas])
      end
    end
  end
  { id: "${google_secret_manager_secret.#{virtual_name}.id}", secret_id: "${google_secret_manager_secret.#{virtual_name}.secret_id}" }
end