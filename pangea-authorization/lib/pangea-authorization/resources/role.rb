def iam_role(context, name:, tags:, assume_role_policy:)
  context.resource :aws_iam_role, name do
    name name
    tags tags
    assume_role_policy assume_role_policy
  end
  {
    arn: "${aws_iam_role.#{name}.arn}",
    name: name
  }
end
