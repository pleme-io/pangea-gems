def google_secret_manager_secret_iam_member(name:, secret_id:, role:, member:)
  resource :google_secret_manager_secret_iam_member, name do
    secret_id secret_id
    role      role
    member    member
  end
  { id: "${google_secret_manager_secret_iam_member.#{name}.id}" }
end