def google_storage_bucket(name:, bucket_name:, location:, force_destroy: nil, uniform_bucket_level_access:, website: nil, storage_class: nil, versioning: nil, lifecycle_rule: nil)
  resource :google_storage_bucket, name do
    name                      bucket_name
    location                  location
    force_destroy             force_destroy unless force_destroy.nil?
    uniform_bucket_level_access uniform_bucket_level_access
    website do
      main_page_suffix website[:main_page_suffix]
    end unless website.nil?
    storage_class storage_class unless storage_class.nil?
    versioning do
      enabled versioning[:enabled]
    end unless versioning.nil?
    lifecycle_rule do
      action do
        type lifecycle_rule[:action][:type]
      end
      condition do
        age lifecycle_rule[:condition][:age]
      end
    end unless lifecycle_rule.nil?
  end
  { name: "${google_storage_bucket.#{name}.name}" }
end