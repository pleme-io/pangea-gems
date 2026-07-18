# lib/pangea-os/sandbox.rb
require 'fileutils'
require 'aws-sdk-s3'
require 'aws-sdk-ec2'
require 'aws-sdk-iam'
module PangeaOS
  class Sandbox
    class << self
      def dir = File.join(ENV.fetch('HOME', nil), '.pangea', 'sandbox')
      def nixpkgs = "#{dir}/nixpkgs"

      def create
        FileUtils.mkdir_p(dir)
        return if Dir.exist?(nixpkgs)

        system 'git', 'clone', 'https://github.com/NixOS/nixpkgs.git', nixpkgs
        Dir.chdir(nixpkgs) { system 'git', 'checkout', 'master' }
      end

      def build
        cmd = "export NIX_PATH=nixpkgs=#{nixpkgs} && nix-build #{nixpkgs}/nixos/release.nix --arg configuration #{File.expand_path('./lib/pangea-os/configuration.nix')} -A amazonImage.x86_64-linux --out-link ami-result"
        cmd = cmd.strip
        puts(cmd)
        system(cmd)
        Dir.glob('ami-result/*.vhd').first
      end

      def upload(bucket = 'pangea-os', region = ENV['AWS_REGION'] || 'us-east-1')
        path = build
        key = File.basename(path)
        Aws::S3::Resource.new(region: region).bucket(bucket).object(key).upload_file(path)
        @last_key = key
        key
      end

      # List all IAM roles in the account
      def list_roles(region: ENV['AWS_REGION'] || 'us-east-1', max_items: 1000)
        iam = Aws::IAM::Client.new(region: region)
        roles = []
        marker = nil
        loop do
          resp = iam.list_roles({ marker: marker, max_items: max_items })
          roles.concat(resp.roles.map(&:role_name))
          break unless resp.is_truncated

          marker = resp.marker
        end
        roles
      end

      # role_arn: 'arn:aws:iam::<ACCOUNT_ID>:role/pangea-os',
      def import_image(key, bucket = 'pangea-os', region = ENV['AWS_REGION'] || 'us-east-1')
        ec2 = Aws::EC2::Client.new(region: region)
        tid = ec2.import_image(
          description: 'Custom NixOS AMI',
          # role_name: 'pangea-os',
          disk_containers: [
            { format: 'VHD', user_bucket: { s3_bucket: bucket, s3_key: key } }
          ]
        ).import_task_id
        loop do
          task = ec2.describe_import_image_tasks(import_task_ids: [tid]).import_image_tasks.first
          return @snapshot = task.snapshot_details.first.snapshot_id if task.status == 'completed'
          raise task.status_message if %w[deleting deleted].include?(task.status)

          sleep 20
        end
      end

      # def register_image(name = 'pangea-os-ami', region = ENV['AWS_REGION'] || 'us-east-1')
      #   ec2 = Aws::EC2::Client.new(region: region)
      #   @ami = ec2.register_image(name: name, architecture: 'x86_64', root_device_name: '/dev/xvda', block_device_mappings: [{ device_name: '/dev/xvda', ebs: { snapshot_id: @snapshot } }]).image_id
      # end

      # def cleanup(region = ENV['AWS_REGION'] || 'us-east-1')
      #   ec2 = Aws::EC2::Client.new(region: region)
      #   ec2.deregister_image(image_id: @ami) if @ami
      #   ec2.delete_snapshot(snapshot_id: @snapshot) if @snapshot
      #   Aws::S3::Client.new(region: region).delete_object(bucket: 'pangea-os', key: @last_key) if @last_key
      #   FileUtils.rm_rf(dir)
      #   system 'nix-store', '--delete', @store if @store
      # end
    end
  end
end
PangeaOS::Sandbox.create
PangeaOS::Sandbox.build
key = PangeaOS::Sandbox.upload
PangeaOS::Sandbox.import_image(key)
PangeaOS::Sandbox.register_image
# …when you’re done and want to tear everything down:
# PangeaOS::Sandbox.cleanup
