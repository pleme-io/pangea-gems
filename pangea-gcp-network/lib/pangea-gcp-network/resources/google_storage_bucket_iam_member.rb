def google_storage_bucket_iam_member(name:, bucket:, role:, member:)
  resource :google_storage_bucket_iam_member, name do
    bucket  bucket
    role    role
    member  member
  end
  { id: "${google_storage_bucket_iam_member.#{name}.id}" }
end