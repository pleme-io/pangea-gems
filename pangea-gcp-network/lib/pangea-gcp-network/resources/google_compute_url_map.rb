def google_compute_url_map(name:, default_service:)
  resource :google_compute_url_map, name do
    name name.to_s.gsub('_', '-')
    default_service default_service
  end
  { id: "${google_compute_url_map.#{name}.id}" }
end