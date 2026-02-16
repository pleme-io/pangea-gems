def google_artifact_registry_repository_iam_member(name:, location:, repository:, role:, member:)
  resource :google_artifact_registry_repository_iam_member, name do
    location    location
    repository  repository
    role        role
    member      member
  end
  { id: "${google_artifact_registry_repository_iam_member.#{name}.id}" }
end