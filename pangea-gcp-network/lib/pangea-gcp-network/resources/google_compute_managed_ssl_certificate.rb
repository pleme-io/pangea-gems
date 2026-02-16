def google_compute_managed_ssl_certificate(name:, managed:)
  resource :google_compute_managed_ssl_certificate, name do
    name name.to_s.gsub('_', '-')
    managed do
      domains managed[:domains]
    end
  end
  { id: "${google_compute_managed_ssl_certificate.#{name}.id}" }
end