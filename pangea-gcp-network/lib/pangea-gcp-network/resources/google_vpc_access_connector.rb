def google_vpc_access_connector(name:, region:, network:, ip_cidr_range:, machine_type:, min_instances:, max_instances:, depends_on:)
  resource :google_vpc_access_connector, name do
    name           name.to_s.gsub('_', '-')
    region         region
    network        network
    ip_cidr_range  ip_cidr_range
    machine_type   machine_type
    min_instances  min_instances
    max_instances  max_instances
    depends_on     depends_on
  end
  { id: "${google_vpc_access_connector.#{name}.id}" }
end