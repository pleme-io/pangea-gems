def google_compute_subnetwork(name:, ip_cidr_range:, region:, network:, private_ip_google_access:, virtual: nil)
  virtual = name if virtual.nil?

  resource :google_compute_subnetwork, virtual.to_s do
    name                    name.to_s
    ip_cidr_range           ip_cidr_range
    region                  region
    network                 network
    private_ip_google_access private_ip_google_access
  end
  { id: "${google_compute_subnetwork.#{name}.id}" }
end
