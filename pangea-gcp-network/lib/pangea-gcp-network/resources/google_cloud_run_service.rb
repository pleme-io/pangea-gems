def google_cloud_run_service(name:, location:, template:, lifecycle:, traffic:, autogenerate_revision_name: nil, virtual: nil)
  virtual_name = virtual || name
  resource :google_cloud_run_service, virtual_name do
    name        name.to_s.gsub('_', '-')
    location    location
    autogenerate_revision_name autogenerate_revision_name unless autogenerate_revision_name.nil?
    template do
      metadata do
        annotations(template[:metadata][:annotations]) if template[:metadata] && template[:metadata][:annotations]
      end
      spec do
        container_concurrency template[:spec][:container_concurrency] if template[:spec] && template[:spec][:container_concurrency]
        containers template[:spec][:containers] if template[:spec] && template[:spec][:containers]
      end
    end
    lifecycle do
      ignore_changes(lifecycle[:ignore_changes]) if lifecycle && lifecycle[:ignore_changes]
    end
    traffic traffic
  end
  { id: "${google_cloud_run_service.#{virtual_name}.id}" }
end