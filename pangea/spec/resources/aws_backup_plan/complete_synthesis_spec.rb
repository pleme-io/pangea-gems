# frozen_string_literal: true

require 'spec_helper'
require 'pangea/resources/aws_backup_plan/resource'
require 'terraform-synthesizer'

RSpec.describe 'aws_backup_plan synthesis' do
  include Pangea::Resources::AWS
  
  let(:synthesizer) { TerraformSynthesizer.new }
  
  describe 'terraform synthesis' do
    context 'minimal configuration' do
      it 'generates basic backup plan' do
        synthesizer.synthesize do
          aws_backup_plan(:basic, {
            name: "basic-backup-plan",
            rule: [{
              rule_name: "BasicRule",
              target_backup_vault_name: "default-vault"
            }]
          })
        end
        
        result = synthesizer.synthesis
        plan = result[:resource][:aws_backup_plan][:basic]
        
        expect(plan[:backup_plan][:backup_plan_name]).to eq("basic-backup-plan")
        expect(plan[:backup_plan][:rule]).to have(1).item
        expect(plan[:backup_plan][:rule].first[:rule_name]).to eq("BasicRule")
        expect(plan[:backup_plan][:rule].first[:target_backup_vault_name]).to eq("default-vault")
        
        # Should not include optional fields
        expect(plan[:backup_plan][:rule].first[:schedule]).to be_nil
        expect(plan[:backup_plan][:advanced_backup_setting]).to be_nil
      end
    end
    
    context 'scheduled backup with lifecycle' do
      it 'generates complete backup rule configuration' do
        synthesizer.synthesize do
          aws_backup_plan(:scheduled, {
            name: "scheduled-backup-plan",
            rule: [{
              rule_name: "DailyBackup",
              target_backup_vault_name: "primary-vault",
              schedule: "cron(0 2 * * ? *)",
              start_window: 90,
              completion_window: 240,
              lifecycle: {
                delete_after: 30
              },
              recovery_point_tags: {
                Environment: "production",
                Backup: "daily"
              }
            }]
          })
        end
        
        result = synthesizer.synthesis
        rule = result[:resource][:aws_backup_plan][:scheduled][:backup_plan][:rule].first
        
        expect(rule[:schedule]).to eq("cron(0 2 * * ? *)")
        expect(rule[:start_window_minutes]).to eq(90)
        expect(rule[:completion_window_minutes]).to eq(240)
        expect(rule[:lifecycle][:delete_after_days]).to eq(30)
        expect(rule[:recovery_point_tags][:Environment]).to eq("production")
        expect(rule[:recovery_point_tags][:Backup]).to eq("daily")
      end
    end
    
    context 'cold storage lifecycle' do
      it 'generates cold storage configuration' do
        synthesizer.synthesize do
          aws_backup_plan(:cold_storage, {
            name: "cold-storage-plan",
            rule: [{
              rule_name: "ArchiveRule",
              target_backup_vault_name: "archive-vault",
              schedule: "cron(0 3 1 * ? *)",
              lifecycle: {
                cold_storage_after: 90,
                delete_after: 2555,
                opt_in_to_archive_for_supported_resources: true
              }
            }]
          })
        end
        
        result = synthesizer.synthesis
        lifecycle = result[:resource][:aws_backup_plan][:cold_storage][:backup_plan][:rule].first[:lifecycle]
        
        expect(lifecycle[:cold_storage_after_days]).to eq(90)
        expect(lifecycle[:delete_after_days]).to eq(2555)
        expect(lifecycle[:opt_in_to_archive_for_supported_resources]).to be true
      end
    end
    
    context 'cross-region copy' do
      it 'generates copy action configuration' do
        synthesizer.synthesize do
          aws_backup_plan(:cross_region, {
            name: "cross-region-plan",
            rule: [{
              rule_name: "PrimaryBackup",
              target_backup_vault_name: "primary-vault",
              schedule: "rate(12 hours)",
              lifecycle: { delete_after: 14 },
              copy_action: [{
                destination_backup_vault_arn: "arn:aws:backup:us-west-2:123456789012:vault:dr-vault",
                lifecycle: {
                  cold_storage_after: 180,
                  delete_after: 365
                }
              }]
            }]
          })
        end
        
        result = synthesizer.synthesis
        copy_action = result[:resource][:aws_backup_plan][:cross_region][:backup_plan][:rule].first[:copy_action].first
        
        expect(copy_action[:destination_backup_vault_arn]).to eq("arn:aws:backup:us-west-2:123456789012:vault:dr-vault")
        expect(copy_action[:lifecycle][:cold_storage_after_days]).to eq(180)
        expect(copy_action[:lifecycle][:delete_after_days]).to eq(365)
      end
    end
    
    context 'continuous backup' do
      it 'generates continuous backup configuration' do
        synthesizer.synthesize do
          aws_backup_plan(:continuous, {
            name: "continuous-backup-plan",
            rule: [{
              rule_name: "ContinuousRule",
              target_backup_vault_name: "continuous-vault",
              schedule: "rate(1 hour)",
              enable_continuous_backup: true
            }]
          })
        end
        
        result = synthesizer.synthesis
        rule = result[:resource][:aws_backup_plan][:continuous][:backup_plan][:rule].first
        
        expect(rule[:enable_continuous_backup]).to be true
      end
    end
    
    context 'advanced backup settings' do
      it 'generates Windows VSS configuration' do
        synthesizer.synthesize do
          aws_backup_plan(:windows, {
            name: "windows-backup-plan",
            rule: [{
              rule_name: "WindowsRule",
              target_backup_vault_name: "windows-vault",
              schedule: "rate(1 day)"
            }],
            advanced_backup_setting: [{
              resource_type: "EC2",
              backup_options: {
                "WindowsVSS" => "enabled",
                "ExcludeDataVolumes" => "false"
              }
            }]
          })
        end
        
        result = synthesizer.synthesis
        setting = result[:resource][:aws_backup_plan][:windows][:backup_plan][:advanced_backup_setting].first
        
        expect(setting[:resource_type]).to eq("EC2")
        expect(setting[:backup_options]["WindowsVSS"]).to eq("enabled")
        expect(setting[:backup_options]["ExcludeDataVolumes"]).to eq("false")
      end
      
      it 'generates RDS backup options' do
        synthesizer.synthesize do
          aws_backup_plan(:rds, {
            name: "rds-backup-plan",
            rule: [{
              rule_name: "DatabaseRule",
              target_backup_vault_name: "db-vault",
              schedule: "rate(1 day)"
            }],
            advanced_backup_setting: [{
              resource_type: "RDS",
              backup_options: {
                "CopyTagsToSnapshot" => "true"
              }
            }]
          })
        end
        
        result = synthesizer.synthesis
        setting = result[:resource][:aws_backup_plan][:rds][:backup_plan][:advanced_backup_setting].first
        
        expect(setting[:resource_type]).to eq("RDS")
        expect(setting[:backup_options]["CopyTagsToSnapshot"]).to eq("true")
      end
    end
    
    context 'multi-rule configuration' do
      it 'generates multiple backup rules' do
        synthesizer.synthesize do
          aws_backup_plan(:multi_rule, {
            name: "multi-rule-plan",
            rule: [
              {
                rule_name: "HourlySnapshots",
                target_backup_vault_name: "frequent-vault",
                schedule: "rate(1 hour)",
                lifecycle: { delete_after: 2 }
              },
              {
                rule_name: "DailyBackups",
                target_backup_vault_name: "daily-vault",
                schedule: "cron(0 2 * * ? *)",
                lifecycle: { delete_after: 30 }
              },
              {
                rule_name: "MonthlyArchives",
                target_backup_vault_name: "archive-vault",
                schedule: "cron(0 3 1 * ? *)",
                lifecycle: {
                  cold_storage_after: 90,
                  delete_after: 365
                }
              }
            ]
          })
        end
        
        result = synthesizer.synthesis
        rules = result[:resource][:aws_backup_plan][:multi_rule][:backup_plan][:rule]
        
        expect(rules).to have(3).items
        expect(rules.map { |r| r[:rule_name] }).to eq(["HourlySnapshots", "DailyBackups", "MonthlyArchives"])
        expect(rules[2][:lifecycle][:cold_storage_after_days]).to eq(90)
      end
    end
    
    context 'conditional field inclusion' do
      it 'excludes default values from output' do
        synthesizer.synthesize do
          aws_backup_plan(:defaults, {
            name: "defaults-test",
            rule: [{
              rule_name: "DefaultRule",
              target_backup_vault_name: "vault",
              schedule: "rate(1 day)",
              start_window: 60,          # Default value
              completion_window: 120,    # Default value
              enable_continuous_backup: false  # Default value
            }]
          })
        end
        
        result = synthesizer.synthesis
        rule = result[:resource][:aws_backup_plan][:defaults][:backup_plan][:rule].first
        
        # Default values should not be included
        expect(rule[:start_window_minutes]).to be_nil
        expect(rule[:completion_window_minutes]).to be_nil
        expect(rule[:enable_continuous_backup]).to be_nil
      end
      
      it 'includes non-default values' do
        synthesizer.synthesize do
          aws_backup_plan(:non_defaults, {
            name: "non-defaults-test",
            rule: [{
              rule_name: "CustomRule",
              target_backup_vault_name: "vault",
              schedule: "rate(1 day)",
              start_window: 90,          # Non-default
              completion_window: 180     # Non-default
            }]
          })
        end
        
        result = synthesizer.synthesis
        rule = result[:resource][:aws_backup_plan][:non_defaults][:backup_plan][:rule].first
        
        expect(rule[:start_window_minutes]).to eq(90)
        expect(rule[:completion_window_minutes]).to eq(180)
      end
    end
    
    context 'reference integration' do
      it 'supports references to backup vaults' do
        synthesizer.synthesize do
          vault_name = "${aws_backup_vault.primary.name}"
          dr_vault_arn = "${aws_backup_vault.dr.arn}"
          
          aws_backup_plan(:integrated, {
            name: "integrated-backup-plan",
            rule: [{
              rule_name: "IntegratedRule",
              target_backup_vault_name: vault_name,
              schedule: "rate(1 day)",
              copy_action: [{
                destination_backup_vault_arn: dr_vault_arn,
                lifecycle: { delete_after: 7 }
              }]
            }]
          })
        end
        
        result = synthesizer.synthesis
        rule = result[:resource][:aws_backup_plan][:integrated][:backup_plan][:rule].first
        
        expect(rule[:target_backup_vault_name]).to eq("${aws_backup_vault.primary.name}")
        expect(rule[:copy_action].first[:destination_backup_vault_arn]).to eq("${aws_backup_vault.dr.arn}")
      end
    end
    
    context 'complex scenarios' do
      it 'generates compliance-focused backup configuration' do
        synthesizer.synthesize do
          aws_backup_plan(:compliance, {
            name: "compliance-backup-plan",
            rule: [{
              rule_name: "ComplianceRule",
              target_backup_vault_name: "compliance-vault",
              schedule: "cron(0 3 * * ? *)",
              start_window: 60,
              completion_window: 360,
              lifecycle: {
                cold_storage_after: 90,
                delete_after: 2555
              },
              recovery_point_tags: {
                Compliance: "Required",
                DataClassification: "Sensitive",
                RetentionYears: "7"
              },
              copy_action: [{
                destination_backup_vault_arn: "arn:aws:backup:eu-west-1:123456789012:vault:compliance-dr",
                lifecycle: { delete_after: 2555 }
              }]
            }],
            tags: {
              Compliance: "SOC2",
              DataProtection: "Critical"
            }
          })
        end
        
        result = synthesizer.synthesis
        plan = result[:resource][:aws_backup_plan][:compliance]
        
        expect(plan[:tags][:Compliance]).to eq("SOC2")
        expect(plan[:backup_plan][:rule].first[:lifecycle][:delete_after_days]).to eq(2555)
        expect(plan[:backup_plan][:rule].first[:recovery_point_tags][:Compliance]).to eq("Required")
      end
      
      it 'generates database-optimized backup configuration' do
        synthesizer.synthesize do
          aws_backup_plan(:database, {
            name: "database-backup-plan",
            rule: [
              {
                rule_name: "TransactionLogs",
                target_backup_vault_name: "db-logs-vault",
                schedule: "rate(1 hour)",
                lifecycle: { delete_after: 3 },
                enable_continuous_backup: true
              },
              {
                rule_name: "DailySnapshots",
                target_backup_vault_name: "db-snapshots-vault",
                schedule: "cron(0 4 * * ? *)",
                lifecycle: { delete_after: 30 }
              }
            ],
            advanced_backup_setting: [
              {
                resource_type: "RDS",
                backup_options: {
                  "CopyTagsToSnapshot" => "true"
                }
              },
              {
                resource_type: "Aurora",
                backup_options: {
                  "BacktrackWindowHours" => "72"
                }
              }
            ]
          })
        end
        
        result = synthesizer.synthesis
        plan = result[:resource][:aws_backup_plan][:database][:backup_plan]
        
        expect(plan[:rule]).to have(2).items
        expect(plan[:rule].first[:enable_continuous_backup]).to be true
        expect(plan[:advanced_backup_setting]).to have(2).items
      end
    end
  end
  
  describe 'error handling in synthesis' do
    it 'prevents invalid terraform generation' do
      expect {
        synthesizer.synthesize do
          aws_backup_plan(:invalid, {
            name: "invalid-plan",
            rule: []  # Empty rules array
          })
        end
      }.to raise_error(Dry::Types::ConstraintError)
    end
  end
end