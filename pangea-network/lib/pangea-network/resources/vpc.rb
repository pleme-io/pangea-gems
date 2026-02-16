# frozen_string_literal: true

def vpc(context, name:, tags:, cidr_block:, enable_dns_support: true, enable_dns_hostnames: true)
  context.resource :aws_vpc, name do
    cidr_block cidr_block
    enable_dns_support enable_dns_support
    tags tags
  end
  {
    arn: "${aws_vpc.#{name}.arn}",
    id: "${aws_vpc.#{name}.id}"
  }
end