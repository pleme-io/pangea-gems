def google_sql_user(name:, instance:, password: nil, virtual: nil)
  virtual_name = virtual || name
  resource :google_sql_user, virtual_name do
    name     name.to_s
    instance instance
    password password unless password.nil?
  end
  { id: "${google_sql_user.#{virtual_name}.id}" }
end