# frozen_string_literal: true

def public_route_table(context, name:, vpc_id:, igw_id:)
  context.resource :aws_route_table, name do
    vpc_id vpc_id
  end

  context.resource :aws_route, :"#{name}_default_route" do
    route_table_id           "${aws_route_table.#{name}.id}"
    destination_cidr_block   '0.0.0.0/0'
    gateway_id               igw_id
  end

  { id: "${aws_route_table.#{name}.id}" }
end
