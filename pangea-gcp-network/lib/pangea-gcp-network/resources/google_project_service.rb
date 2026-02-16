def google_project_service(name:, service:)
  resource :google_project_service, name do
    service service
  end
  { id: "${google_project_service.#{name}.id}" }
end