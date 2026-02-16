def google_project_iam_member(name:, role:, member:, project:)
  resource :google_project_iam_member, name do
    role   role
    member member
    project project
  end
  { id: "${google_project_iam_member.#{name}.id}" }
end