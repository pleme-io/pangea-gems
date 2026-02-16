def google_network_services_mesh(name:, location:)
  resource :google_network_services_mesh, name do
    name     name.to_s.gsub('_', '-')
    location location
  end
  { id: "${google_network_services_mesh.#{name}.id}" }
end