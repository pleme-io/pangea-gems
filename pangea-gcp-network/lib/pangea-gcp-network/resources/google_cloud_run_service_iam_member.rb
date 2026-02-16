def google_cloud_run_service_iam_member(name:, service:, location:, role:, member:)
  resource :google_cloud_run_service_iam_member, name do
    service  service
    location location
    role     role
    member   member
  end
  { id: "${google_cloud_run_service_iam_member.#{name}.id}" }
end