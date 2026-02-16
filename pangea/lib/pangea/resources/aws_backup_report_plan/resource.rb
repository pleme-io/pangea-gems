# frozen_string_literal: true

require 'pangea/resources/base'
require 'pangea/resources/reference'

module Pangea
  module Resources
    module AWS
      # Type-safe resource function for AWS Backup Report Plan
      #
      # @param name [Symbol] The resource name
      # @param attributes [Hash] Resource attributes following AWS provider schema
      # @return [Pangea::Resources::Reference] Resource reference for chaining
      # 
      # @see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_report_plan
      #
      # @example Daily backup job report plan
      #   aws_backup_report_plan(:daily_backup_report, {
      #     name: "DailyBackupJobReport",
      #     description: "Daily report on backup job status and compliance",
      #     report_delivery_channel: {
      #       s3_bucket_name: reports_bucket.bucket,
      #       s3_key_prefix: "backup-reports/daily/",
      #       formats: ["CSV", "JSON"]
      #     },
      #     report_setting: {
      #       report_template: "BACKUP_JOB_REPORT",
      #       framework_arns: [compliance_framework.arn],
      #       accounts: [data.aws_caller_identity.current.account_id],
      #       organization_units: [],
      #       regions: ["us-east-1", "us-west-2"]
      #     },
      #     tags: {
      #       ReportType: "backup-compliance",
      #       Frequency: "daily"
      #     }
      #   })
      #
      # @example Restore job testing report
      #   aws_backup_report_plan(:restore_test_report, {
      #     name: "RestoreJobTestingReport",
      #     description: "Weekly report on backup restore testing results",
      #     report_delivery_channel: {
      #       s3_bucket_name: "backup-reports-bucket",
      #       s3_key_prefix: "restore-reports/weekly/",
      #       formats: ["CSV"]
      #     },
      #     report_setting: {
      #       report_template: "RESTORE_JOB_REPORT",
      #       accounts: ["123456789012"],
      #       regions: ["us-east-1"]
      #     }
      #   })
      def aws_backup_report_plan(name, attributes)
        transformed = Base.transform_attributes(attributes, {
          name: {
            description: "Name of the backup report plan",
            type: :string,
            required: true
          },
          description: {
            description: "Description of the backup report plan",
            type: :string
          },
          report_delivery_channel: {
            description: "Configuration for report delivery",
            type: :hash,
            required: true,
            properties: {
              s3_bucket_name: {
                description: "S3 bucket name for report delivery",
                type: :string,
                required: true
              },
              s3_key_prefix: {
                description: "S3 key prefix for report objects",
                type: :string
              },
              formats: {
                description: "Report formats (CSV, JSON)",
                type: :array
              }
            }
          },
          report_setting: {
            description: "Settings for the report",
            type: :hash,
            required: true,
            properties: {
              report_template: {
                description: "Report template name",
                type: :string,
                required: true
              },
              framework_arns: {
                description: "List of framework ARNs to include",
                type: :array
              },
              accounts: {
                description: "List of account IDs to include",
                type: :array
              },
              organization_units: {
                description: "List of organization unit IDs",
                type: :array
              },
              regions: {
                description: "List of regions to include",
                type: :array
              }
            }
          },
          tags: {
            description: "Resource tags",
            type: :map
          }
        })

        resource_block = resource(:aws_backup_report_plan, name, transformed)
        
        Reference.new(
          type: :aws_backup_report_plan,
          name: name,
          attributes: {
            arn: "#{resource_block}.arn",
            id: "#{resource_block}.id",
            name: "#{resource_block}.name",
            tags_all: "#{resource_block}.tags_all"
          },
          resource: resource_block
        )
      end
    end
  end
end

# Auto-register this module when it's loaded
Pangea::ResourceRegistry.register(:aws, Pangea::Resources::AWS)