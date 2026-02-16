def google_compute_firewall(name:, network:, source_ranges:, allow:, virtual: nil)
  virtual_name = virtual || name
  resource :google_compute_firewall, virtual_name do
    name          name.to_s.gsub('_', '-')
    network       network
    source_ranges source_ranges
    allow allow
  end
  { id: "${google_compute_firewall.#{virtual_name}.id}" }
end