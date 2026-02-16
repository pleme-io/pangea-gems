# frozen_string_literal: true

def igw(context, name:, vpc_id:, tags:)
  context.resource :aws_internet_gateway, name do
    vpc_id vpc_id
    tags tags
  end
  {
    arn: "${aws_internet_gateway.#{name}.arn}",
    id: "${aws_internet_gateway.#{name}.id}"
  }
end