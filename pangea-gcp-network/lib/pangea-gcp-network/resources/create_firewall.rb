def google_compute_firewall(name:, network:, source_ranges:, allow:)
  resource :google_compute_firewall, name do
    name          name.to_s.gsub('_', '-')
    network       network
    source_ranges source_ranges
    allow allow
  end
  { id: "${google_compute_firewall.#{name}.id}" }
end