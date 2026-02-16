def google_compute_network(name:, auto_create_subnetworks:, virtual: nil)
  virtual_name = virtual || name
  resource :google_compute_network, virtual_name do
    name                    name.to_s
    auto_create_subnetworks auto_create_subnetworks
  end
  { id: "${google_compute_network.#{virtual_name}.id}" }
end
