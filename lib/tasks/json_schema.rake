require 'json-schema'

namespace :json_schema do
  desc "validate all HcVisit data against JSON schema"
  task :validate => :environment do
    snapshot = ConfigSnapshot.first
    hcv_schema = snapshot.json_schema

    HcVisit.scoped.each_with_index do |hcv,idx|
      result = JSON::Validator.fully_validate hcv_schema, hcv.data
      if result.any?
        puts '-' * 78
        puts "HcVisit[#{idx}] ID: #{hcv.id}:"
        puts result
      end
    end
  end
end


