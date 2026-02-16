# frozen_string_literal: true

def subnet(
  context,
  name:,
  tags:,
  vpc_id:,
  cidr_block:,
  availability_zone:,
  map_public_ip_on_launch: false
)
  context.resource :aws_subnet, name do
    vpc_id vpc_id
    cidr_block cidr_block
    map_public_ip_on_launch map_public_ip_on_launch
    availability_zone availability_zone
    tags tags
  end
  {id: "${aws_subnet.#{name}.id}"}
end