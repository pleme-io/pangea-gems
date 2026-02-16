# frozen_string_literal: true

require 'spec_helper'
require 'pangea/resources/aws_backup_plan/resource'

RSpec.describe 'aws_backup_plan' do
  include Pangea::Resources::AWS
  
  describe 'resource function' do
    context 'with minimal configuration' do
      it 'creates backup plan with single rule' do
        ref = aws_backup_plan(:simple, {
          name: "simple-backup-plan",
          rule: [{
            rule_name: "DailyBackup",
            target_backup_vault_name: "default-vault"
          }]
        })
        
        expect(ref).to be_a(Pangea::Resources::ResourceReference)
        expect(ref.type).to eq('aws_backup_plan')
        expect(ref.name).to eq(:simple)
        expect(ref[:name]).to eq("simple-backup-plan")
        expect(ref[:rule_count]).to eq(1)
      end
    end
    
    context 'with scheduled backups' do
      it 'creates plan with cron schedule' do
        ref = aws_backup_plan(:scheduled, {
          name: "scheduled-backup-plan",
          rule: [{
            rule_name: "NightlyBackup",
            target_backup_vault_name: "primary-vault",
            schedule: "cron(0 2 * * ? *)",
            start_window: 60,
            completion_window: 180
          }]
        })
        
        expect(ref.resource_attributes[:rule].first.schedule).to eq("cron(0 2 * * ? *)")
        expect(ref.backup_frequency).to eq("daily")
      end
      
      it 'creates plan with rate schedule' do
        ref = aws_backup_plan(:hourly, {
          name: "hourly-backup-plan",
          rule: [{
            rule_name: "HourlyBackup",
            target_backup_vault_name: "frequent-vault",
            schedule: "rate(1 hour)"
          }]
        })
        
        expect(ref.backup_frequency).to eq("hourly")
      end
    end
    
    context 'with lifecycle policies' do
      it 'configures retention policies' do
        ref = aws_backup_plan(:retention, {
          name: "retention-backup-plan",
          rule: [{
            rule_name: "RetentionRule",
            target_backup_vault_name: "retention-vault",
            schedule: "rate(1 day)",
            lifecycle: {
              delete_after: 30
            }
          }]
        })
        
        expect(ref.has_lifecycle_policies?).to be true
        expect(ref.total_retention_days).to eq(30)
        expect(ref.uses_cold_storage?).to be false
      end
      
      it 'configures cold storage transition' do
        ref = aws_backup_plan(:cold_storage, {
          name: "cold-storage-plan",
          rule: [{
            rule_name: "ArchiveRule",
            target_backup_vault_name: "archive-vault",
            schedule: "cron(0 3 1 * ? *)",
            lifecycle: {
              cold_storage_after: 90,
              delete_after: 2555
            }
          }]
        })
        
        expect(ref.uses_cold_storage?).to be true
        expect(ref.total_retention_days).to eq(2555)
      end
    end
    
    context 'with cross-region copies' do
      it 'configures copy actions' do
        ref = aws_backup_plan(:cross_region, {
          name: "cross-region-plan",
          rule: [{
            rule_name: "PrimaryBackup",
            target_backup_vault_name: "primary-vault",
            schedule: "rate(12 hours)",
            lifecycle: { delete_after: 14 },
            copy_action: [{
              destination_backup_vault_arn: "arn:aws:backup:us-west-2:123456789012:vault:dr-vault",
              lifecycle: { delete_after: 7 }
            }]
          }]
        })
        
        expect(ref.has_cross_region_copies?).to be true
        expect(ref.resource_attributes[:rule].first.copy_action).to have(1).item
      end
    end
    
    context 'with continuous backup' do
      it 'enables continuous backup for supported services' do
        ref = aws_backup_plan(:continuous, {
          name: "continuous-backup-plan",
          rule: [{
            rule_name: "ContinuousRule",
            target_backup_vault_name: "continuous-vault",
            enable_continuous_backup: true
          }]
        })
        
        expect(ref.supports_continuous_backup?).to be true
      end
    end
    
    context 'with advanced settings' do
      it 'configures Windows VSS for application consistency' do
        ref = aws_backup_plan(:windows, {
          name: "windows-backup-plan",
          rule: [{
            rule_name: "WindowsBackup",
            target_backup_vault_name: "windows-vault",
            schedule: "rate(1 day)"
          }],
          advanced_backup_setting: [{
            resource_type: "EC2",
            backup_options: {
              "WindowsVSS" => "enabled"
            }
          }]
        })
        
        expect(ref.resource_attributes[:advanced_backup_setting]).to have(1).item
        expect(ref.resource_attributes[:advanced_backup_setting].first.resource_type).to eq("EC2")
      end
    end
  end
  
  describe 'type validation' do
    context 'rule validation' do
      it 'requires at least one rule' do
        expect {
          aws_backup_plan(:invalid, {
            name: "no-rules-plan",
            rule: []
          })
        }.to raise_error(Dry::Types::ConstraintError, /min_size/)
      end
      
      it 'requires unique rule names' do
        expect {
          aws_backup_plan(:invalid, {
            name: "duplicate-rules",
            rule: [
              { rule_name: "Rule1", target_backup_vault_name: "vault" },
              { rule_name: "Rule1", target_backup_vault_name: "vault" }
            ]
          })
        }.to raise_error(Dry::Struct::Error, /must be unique/)
      end
      
      it 'requires at least one rule with schedule' do
        expect {
          aws_backup_plan(:invalid, {
            name: "no-schedule-plan",
            rule: [{
              rule_name: "UnscheduledRule",
              target_backup_vault_name: "vault"
              # No schedule defined
            }]
          })
        }.to raise_error(Dry::Struct::Error, /must have a schedule/)
      end
    end
    
    context 'schedule validation' do
      it 'validates cron expression format' do
        expect {
          aws_backup_plan(:invalid, {
            name: "bad-schedule",
            rule: [{
              rule_name: "BadCron",
              target_backup_vault_name: "vault",
              schedule: "0 2 * * ?"  # Missing cron() wrapper
            }]
          })
        }.to raise_error(Dry::Struct::Error, /valid cron\(\) or rate\(\)/)
      end
      
      it 'validates rate expression format' do
        expect {
          aws_backup_plan(:invalid, {
            name: "bad-rate",
            rule: [{
              rule_name: "BadRate",
              target_backup_vault_name: "vault",
              schedule: "every hour"  # Invalid format
            }]
          })
        }.to raise_error(Dry::Struct::Error, /valid cron\(\) or rate\(\)/)
      end
      
      it 'accepts valid schedule formats' do
        plan = aws_backup_plan(:valid_schedules, {
          name: "valid-schedules",
          rule: [
            {
              rule_name: "CronRule",
              target_backup_vault_name: "vault",
              schedule: "cron(0 2 * * ? *)"
            },
            {
              rule_name: "RateRule", 
              target_backup_vault_name: "vault",
              schedule: "rate(6 hours)"
            }
          ]
        })
        
        expect(plan.resource_attributes[:rule]).to have(2).items
      end
    end
    
    context 'lifecycle validation' do
      it 'validates delete_after is greater than cold_storage_after' do
        expect {
          aws_backup_plan(:invalid, {
            name: "bad-lifecycle",
            rule: [{
              rule_name: "BadLifecycle",
              target_backup_vault_name: "vault",
              schedule: "rate(1 day)",
              lifecycle: {
                cold_storage_after: 180,
                delete_after: 90  # Less than cold storage
              }
            }]
          })
        }.to raise_error(Dry::Struct::Error, /must be greater than cold_storage_after/)
      end
      
      it 'validates cold storage minimum of 90 days' do
        expect {
          aws_backup_plan(:invalid, {
            name: "short-cold-storage",
            rule: [{
              rule_name: "ShortCold",
              target_backup_vault_name: "vault",
              schedule: "rate(1 day)",
              lifecycle: {
                cold_storage_after: 30,  # Too short
                delete_after: 180
              }
            }]
          })
        }.to raise_error(Dry::Struct::Error, /at least 90 days/)
      end
    end
    
    context 'backup window validation' do
      it 'validates minimum start window' do
        expect {
          aws_backup_plan(:invalid, {
            name: "short-start-window",
            rule: [{
              rule_name: "ShortWindow",
              target_backup_vault_name: "vault",
              schedule: "rate(1 day)",
              start_window: 30  # Too short
            }]
          })
        }.to raise_error(Dry::Struct::Error, /at least 60 minutes/)
      end
      
      it 'validates minimum completion window' do
        expect {
          aws_backup_plan(:invalid, {
            name: "short-completion-window",
            rule: [{
              rule_name: "ShortCompletion",
              target_backup_vault_name: "vault",
              schedule: "rate(1 day)",
              completion_window: 60  # Too short
            }]
          })
        }.to raise_error(Dry::Struct::Error, /at least 120 minutes/)
      end
    end
    
    context 'advanced settings validation' do
      it 'validates resource type constraints' do
        expect {
          aws_backup_plan(:invalid, {
            name: "invalid-resource-type",
            rule: [{
              rule_name: "Rule",
              target_backup_vault_name: "vault",
              schedule: "rate(1 day)"
            }],
            advanced_backup_setting: [{
              resource_type: "Lambda",  # Not supported
              backup_options: {}
            }]
          })
        }.to raise_error(Dry::Types::ConstraintError)
      end
    end
  end
  
  describe 'computed properties' do
    context 'backup frequency analysis' do
      it 'identifies hourly backups' do
        ref = aws_backup_plan(:hourly, {
          name: "hourly-plan",
          rule: [{
            rule_name: "Hourly",
            target_backup_vault_name: "vault",
            schedule: "rate(1 hour)"
          }]
        })
        
        expect(ref.backup_frequency).to eq("hourly")
      end
      
      it 'identifies daily backups' do
        ref = aws_backup_plan(:daily, {
          name: "daily-plan",
          rule: [{
            rule_name: "Daily",
            target_backup_vault_name: "vault",
            schedule: "cron(0 2 * * ? *)"
          }]
        })
        
        expect(ref.backup_frequency).to eq("daily")
      end
      
      it 'identifies weekly backups' do
        ref = aws_backup_plan(:weekly, {
          name: "weekly-plan",
          rule: [{
            rule_name: "Weekly",
            target_backup_vault_name: "vault",
            schedule: "cron(0 0 ? * 1 *)"
          }]
        })
        
        expect(ref.backup_frequency).to eq("weekly")
      end
      
      it 'identifies monthly backups' do
        ref = aws_backup_plan(:monthly, {
          name: "monthly-plan",
          rule: [{
            rule_name: "Monthly",
            target_backup_vault_name: "vault",
            schedule: "cron(0 0 1 * ? *)"
          }]
        })
        
        expect(ref.backup_frequency).to eq("monthly")
      end
    end
    
    context 'cost estimation' do
      it 'estimates costs for simple daily backup' do
        ref = aws_backup_plan(:daily_cost, {
          name: "daily-cost-plan",
          rule: [{
            rule_name: "Daily",
            target_backup_vault_name: "vault",
            schedule: "rate(1 day)",
            lifecycle: { delete_after: 30 }
          }]
        })
        
        cost = ref.estimated_monthly_cost
        expect(cost).to include(:storage, :restore_testing, :total, :note)
        expect(cost[:total]).to be > 0
      end
      
      it 'estimates higher costs for frequent backups' do
        hourly = aws_backup_plan(:hourly_cost, {
          name: "hourly-cost",
          rule: [{
            rule_name: "Hourly",
            target_backup_vault_name: "vault",
            schedule: "rate(1 hour)",
            lifecycle: { delete_after: 7 }
          }]
        })
        
        daily = aws_backup_plan(:daily_cost, {
          name: "daily-cost",
          rule: [{
            rule_name: "Daily",
            target_backup_vault_name: "vault",
            schedule: "rate(1 day)",
            lifecycle: { delete_after: 7 }
          }]
        })
        
        expect(hourly.estimated_monthly_cost[:storage]).to be > daily.estimated_monthly_cost[:storage]
      end
      
      it 'includes cold storage savings' do
        ref = aws_backup_plan(:cold_cost, {
          name: "cold-storage-cost",
          rule: [{
            rule_name: "Archive",
            target_backup_vault_name: "vault",
            schedule: "rate(1 day)",
            lifecycle: {
              cold_storage_after: 90,
              delete_after: 365
            }
          }]
        })
        
        # Cold storage should reduce costs
        cost = ref.estimated_monthly_cost
        expect(cost[:storage]).to be > 0
      end
    end
  end
  
  describe 'resource outputs' do
    it 'provides comprehensive outputs' do
      ref = aws_backup_plan(:outputs, {
        name: "output-test-plan",
        rule: [{
          rule_name: "TestRule",
          target_backup_vault_name: "test-vault",
          schedule: "rate(1 day)"
        }]
      })
      
      # Core outputs
      expect(ref.id).to eq("${aws_backup_plan.outputs.id}")
      expect(ref.arn).to eq("${aws_backup_plan.outputs.arn}")
      expect(ref.version).to eq("${aws_backup_plan.outputs.version}")
      
      # Plan details
      expect(ref[:name]).to eq("output-test-plan")
      expect(ref.tags_all).to eq("${aws_backup_plan.outputs.tags_all}")
      expect(ref[:rule_count]).to eq(1)
    end
  end
  
  describe 'integration patterns' do
    it 'supports compliance backup strategy' do
      ref = aws_backup_plan(:compliance, {
        name: "compliance-backup",
        rule: [{
          rule_name: "ComplianceDaily",
          target_backup_vault_name: "compliance-vault",
          schedule: "cron(0 3 * * ? *)",
          lifecycle: {
            cold_storage_after: 90,
            delete_after: 2555  # 7 years
          },
          recovery_point_tags: {
            Compliance: "Required",
            DataClassification: "Sensitive"
          }
        }],
        tags: {
          Compliance: "SOC2",
          Retention: "7Years"
        }
      })
      
      expect(ref.total_retention_days).to eq(2555)
      expect(ref.uses_cold_storage?).to be true
    end
    
    it 'supports tiered backup strategy' do
      ref = aws_backup_plan(:tiered, {
        name: "tiered-backup",
        rule: [
          {
            rule_name: "Frequent",
            target_backup_vault_name: "hot-vault",
            schedule: "rate(6 hours)",
            lifecycle: { delete_after: 2 }
          },
          {
            rule_name: "Daily",
            target_backup_vault_name: "warm-vault",
            schedule: "rate(1 day)",
            lifecycle: { delete_after: 30 }
          },
          {
            rule_name: "Monthly",
            target_backup_vault_name: "cold-vault",
            schedule: "rate(30 days)",
            lifecycle: {
              cold_storage_after: 90,
              delete_after: 365
            }
          }
        ]
      })
      
      expect(ref[:rule_count]).to eq(3)
      expect(ref.backup_frequency).to eq("hourly")  # Most frequent wins
    end
    
    it 'supports disaster recovery pattern' do
      ref = aws_backup_plan(:dr, {
        name: "dr-backup",
        rule: [{
          rule_name: "PrimaryWithDR",
          target_backup_vault_name: "primary-vault",
          schedule: "rate(12 hours)",
          lifecycle: { delete_after: 14 },
          copy_action: [{
            destination_backup_vault_arn: "arn:aws:backup:us-west-2:123456789012:vault:dr-vault",
            lifecycle: { delete_after: 7 }
          }],
          enable_continuous_backup: true
        }]
      })
      
      expect(ref.has_cross_region_copies?).to be true
      expect(ref.supports_continuous_backup?).to be true
    end
  end
  
  describe 'edge cases' do
    it 'handles plans with recovery point tags' do
      ref = aws_backup_plan(:tagged, {
        name: "tagged-backup",
        rule: [{
          rule_name: "TaggedRule",
          target_backup_vault_name: "vault",
          schedule: "rate(1 day)",
          recovery_point_tags: {
            Project: "WebApp",
            Environment: "Production",
            CostCenter: "IT"
          }
        }]
      })
      
      rule = ref.resource_attributes[:rule].first
      expect(rule.recovery_point_tags).to include(Project: "WebApp")
    end
    
    it 'handles multiple copy actions' do
      ref = aws_backup_plan(:multi_copy, {
        name: "multi-copy-backup",
        rule: [{
          rule_name: "MultiRegionCopy",
          target_backup_vault_name: "primary",
          schedule: "rate(1 day)",
          copy_action: [
            {
              destination_backup_vault_arn: "arn:aws:backup:us-west-2:123456789012:vault:dr1",
              lifecycle: { delete_after: 7 }
            },
            {
              destination_backup_vault_arn: "arn:aws:backup:eu-west-1:123456789012:vault:dr2",
              lifecycle: { delete_after: 3 }
            }
          ]
        }]
      })
      
      expect(ref.resource_attributes[:rule].first.copy_action).to have(2).items
    end
    
    it 'handles advanced backup settings for multiple resource types' do
      ref = aws_backup_plan(:advanced, {
        name: "advanced-settings",
        rule: [{
          rule_name: "Rule",
          target_backup_vault_name: "vault",
          schedule: "rate(1 day)"
        }],
        advanced_backup_setting: [
          {
            resource_type: "EC2",
            backup_options: { "WindowsVSS" => "enabled" }
          },
          {
            resource_type: "RDS",
            backup_options: { "CopyTagsToSnapshot" => "true" }
          }
        ]
      })
      
      expect(ref.resource_attributes[:advanced_backup_setting]).to have(2).items
    end
  end
end