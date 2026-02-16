# gems/pangea-authorization/lib/pangea-authorization/resources/policy.rb
require 'json'
def iam_policy(context, name:, desc:, content:, role:)
  context.resource :aws_iam_policy, name do
    name name
    description desc
    policy(JSON[content])
  end
  context.resource :aws_iam_role_policy_attachment, name do
    role role
    policy_arn "${aws_iam_policy.#{name}.arn}"
  end
end
