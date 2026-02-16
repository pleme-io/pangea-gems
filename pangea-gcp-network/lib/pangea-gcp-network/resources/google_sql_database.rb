def google_sql_database(name:, instance:, virtual: nil)
  virtual_name = virtual || name
  resource :google_sql_database, virtual_name do
    name     name.to_s
    instance instance
  end
  { id: "${google_sql_database.#{virtual_name}.id}" }
end