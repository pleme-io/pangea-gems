def google_sql_database_instance(name:, database_version:, region:, settings:, depends_on:, deletion_protection: true, virtual: nil)
  virtual_name = virtual || name
  resource :google_sql_database_instance, virtual_name do
    name             name.to_s.gsub('_', '-')
    database_version database_version
    region           region
    settings do
      tier settings[:tier]
      ip_configuration do
        private_network settings[:ip_configuration][:private_network]
      end
    end
    depends_on depends_on
  end
  { name: "${google_sql_database_instance.#{virtual_name}.name}" }
end