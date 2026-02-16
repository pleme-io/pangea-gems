def google_compute_target_http_proxy(name:, url_map:)
  resource :google_compute_target_http_proxy, name do
    name name.to_s.gsub('_', '-')
    url_map url_map
  end
  { id: "${google_compute_target_http_proxy.#{name}.id}" }
end