#!/usr/bin/env ruby
#
# Updates month and/or visited_at fields for HcVisits.  Takes a CSV file similar to:
#
#   "code","province_code","month","month_update","visited_at","visited_at_update"
#   "diaca-mocimboa-da-praia-2012-12","cabo-delgado",2012-12-01,2013-01-01,2012-12-19,2013-01-19
#   "mbau-mocimboa-da-praia-2012-12","cabo-delgado",2012-12-01,2013-01-01,2012-12-19,2013-01-19
#
#

require 'csv'

infile = ENV['FILENAME'] ? File.open(ENV['FILENAME'], 'rb') : $stdin

csv = CSV.new(infile,
  :headers        => true,
  :return_headers => true,
  :write_headers  => true,
  :skip_blanks    => true,
)

header = csv.readline

HcVisit.transaction do
  @taken = []

  csv.each do |row|
    data = row.to_hash

    full_code = "#{data['province_code']}/#{data['code']}" # province/hc_visit_code
    unless hcv = HcVisit.where(:province_code => data['province_code'], :code => data['code']).first
      raise "couldn't find visit '#{full_code}'"
    end

    %w(month month_update visited_at visited_at_update).each do |field|
      data[field] = nil if data[field].blank?
      unless data[field].nil? || data[field] =~ /\A201[2-3]-(?:0[1-9]|1[0-2])-(?:[0-2][0-9]|3[0-1])\Z/ # YYYY-MM-DD format
        raise "#{full_code}: invalid data for '#{field}' field: #{data[field]}"
      end
    end

    if data['month'] && hcv.month.to_s != data['month']
      raise "#{full_code}: expected month to be '#{data['month']}', was '#{hcv.month}'"
    end

    if data['visited_at'] && hcv.visited_at.to_s != data['visited_at']
      raise "#{full_code}: expected visited_at to be '#{data['visited_at']}', was '#{hcv.visited_at}'"
    end

    if (visited_at = data['visited_at_update'])
      puts "#{full_code}: changing visited_at from '#{hcv.visited_at}' to '#{visited_at}'"
      hcv.data = hcv.data.merge('visited_at' => visited_at)
      hcv.visited_at = visited_at
    end

    if (month = data['month_update'])
      puts "#{full_code}: changing month from '#{hcv.month}' to '#{month}'"
      code = "#{hcv.health_center_code}-#{month[/^\d{4}-\d{2}/]}"

      hcv.data = hcv.data.merge('month' => month, 'code' => code)
      hcv.month = month
      hcv.code = code
    end

    puts

    begin
      hcv.save!
    rescue ActiveRecord::RecordInvalid => e
      if e.message =~ /already been taken/
        @taken << "#{hcv.province_code}/#{hcv.code}"
      else
        raise
      end
    end

  end

  if @taken.any?
    raise "records already exist for:\n" + @taken.map {|c| " - #{c}\n"}.join
  end
end
