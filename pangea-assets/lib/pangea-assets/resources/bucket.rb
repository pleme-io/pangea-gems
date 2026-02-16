# gems/pangea-authorization/lib/pangea-assets/resources/bucket.rb
def bucket(context, name:, tags:)
  context.resource :aws_s3_bucket, name do
    bucket(name)
    tags(tags)
  end
  { name: name, arn: "${aws_s3_bucket.#{name}.arn}" }
end
