def google_artifact_registry_repository(name:, format:, repository_id:, location:, description:, project:, depends_on:, cleanup_policies:)
  resource :google_artifact_registry_repository, name do
    format        format
    repository_id repository_id
    location      location
    description   description
    project       project
    depends_on    depends_on
    cleanup_policies cleanup_policies
  end
  { id: "${google_artifact_registry_repository.#{name}.id}" }
end