Province.scoped.each do |province|
  puts "-" * 64
  puts "#{province.code}:"
  puts "-" * (province.code.length + 1)
  puts
  puts "Legend:"
  puts "! visited_at date is off by over a month"
  puts "> recorded with the month before the visited_at date"
  puts "< recorded with the month after the visited_at date"
  puts ". month has no visit recorded"
  puts "x month has a visit recorded w/ a visited_at date"
  puts "- month has a visit recorded w/o a visited_at date"
  puts
  puts "(< and > represent the direction visit has been shifted)"
  puts

  province.health_centers.each do |hc|
    header = ' 2010  '
    flags = exists = notes = ''

    month = Date.parse('2010-06-01')
    while month < Date.today
      hcv = HcVisit.where(
        :province_code => province.code,
        :health_center_code => hc.code,
        :month => month
      ).first

      if month.month == 1
        header += "| #{month.year}       "
        flags  += '|'
        exists += '|'
      end

      if hcv
        if hcv.visited_at.nil?
          flags += ' '
          exists += '-' 
        elsif hcv.visited_at > (hcv.month + 2.months) || hcv.visited_at < (hcv.month - 1.months)
          flags += '!'
          notes += "month #{hcv.month}: has visited_at date of #{hcv.visited_at}\n"
          exists += 'x'
        elsif hcv.visited_at < hcv.month
          flags += '>'
          notes += "month #{hcv.month}: has visited_at date of #{hcv.visited_at}\n"
          exists += 'x'
        elsif hcv.visited_at > (hcv.month + 1.month)
          flags += '<'
          notes += "month #{hcv.month}: has visited_at date of #{hcv.visited_at}\n"
          exists += 'x'
        else
          flags += ' '
          exists += 'x'
        end
      else
        flags  += ' '
        exists += '.'
      end

      month += 1.month
    end

    unless notes.empty?
      puts "-" * (hc.code.length + 1)
      puts "#{hc.code}:"
      puts "-" * (hc.code.length + 1)

      puts "  year: #{header}"
      puts " flags: #{flags}"
      puts "visits: #{exists}"

      puts
      puts notes

      puts
    end

  end

end
