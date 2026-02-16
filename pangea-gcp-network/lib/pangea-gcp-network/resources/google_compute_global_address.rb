def google_compute_global_address(name:, purpose:, address_type:, prefix_length:, network:, virtual: nil)
  virtual_name = virtual || name
  resource :google_compute_global_address, virtual_name do
    name          name.to_s.gsub('_', '-')
    purpose       purpose
    address_type  address_type
    prefix_length prefix_length
    network network
  end
  { id: "${google_compute_global_address.#{virtual_name}.id}" }
end