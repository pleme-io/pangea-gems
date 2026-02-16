def google_service_networking_connection(name:, network:, service:, reserved_peering_ranges:, virtual: nil)
  virtual_name = virtual || name
  resource :google_service_networking_connection, virtual_name do
    network                 network
    service                 service
    reserved_peering_ranges reserved_peering_ranges
  end
  { id: "${google_service_networking_connection.#{virtual_name}.id}" }
end