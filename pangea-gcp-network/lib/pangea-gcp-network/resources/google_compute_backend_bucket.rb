def google_compute_backend_bucket(name:, bucket_name:, enable_cdn:)
  resource :google_compute_backend_bucket, name do
    name name.to_s.gsub('_', '-')
    bucket_name bucket_name
    enable_cdn enable_cdn
  end
  { id: "${google_compute_backend_bucket.#{name}.id}" }
end