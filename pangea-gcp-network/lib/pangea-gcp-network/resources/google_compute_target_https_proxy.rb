def google_compute_target_https_proxy(name:, ssl_certificates:, url_map:)
  resource :google_compute_target_https_proxy, name do
    name name.to_s.gsub('_', '-')
    ssl_certificates ssl_certificates
    url_map url_map
  end
  { id: "${google_compute_target_https_proxy.#{name}.id}" }
end