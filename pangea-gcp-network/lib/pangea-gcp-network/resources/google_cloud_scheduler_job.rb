def google_cloud_scheduler_job(name:, description:, schedule:, time_zone:, attempt_deadline:, region:, retry_config:, http_target:)
  resource :google_cloud_scheduler_job, name do
    name             name.to_s.gsub('_', '-')
    description      description
    schedule         schedule
    time_zone        time_zone
    attempt_deadline attempt_deadline
    region           region

    retry_config do
      retry_count retry_config[:retry_count]
    end

    http_target do
      http_method http_target[:http_method]
      uri         http_target[:uri]
      body        http_target[:body]
      headers(http_target[:headers])
    end
  end
  { id: "${google_cloud_scheduler_job.#{name}.id}" }
end