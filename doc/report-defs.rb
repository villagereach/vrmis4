=======



report scope:   
  * always single month, for this release.  no cross-month calculations.
  * geoscope can vary from Province down to single HC (in drilldown). 
 => together, that provides  a set of HCVisits to walk over.   The count of all HCs for the geoscope is also sometimes used.

As seen in current version: 
* Each of these reports  will start with summary numbers for the entire province, one row for each of the last N months.  N=3 for now.
* Each month row is then expandable, showing geoscopes:  Dzones (showing Districts) then Districts (showing HCs)
* a Summary report is scoped to one geoscope and one month, and then shows that scope-and-month row for every report type.   No additional calculation code.  
 => Thus, each of these report types could be done with a js 'partial', passed the month and scope, and easily assembled into 

Other notes:
* Translation codes are conceptual not actual, but they should all exist 1-for-1
# TODO:  review and take more care with using product.code e.g. in references.  Often just product now.


#initial data to set up:
hcs = all HCs within scope  (whether or not there is a visit record)
hc_count = hcs.size
hcvs = all HCVisit records within scope
hcvs_visited = hcvs.select{|hcv| hcv.visited}      #non-"visited" hc_visits are often ignored in calculation.   A definite index for the db.
# most reports walk one of those two.   TODO: walk once; set up a way to pick from the list of calculations to do on each visit?

#helpers/partials:
to_pct(num,denom)  = helper to make integer pct, returns string "46%" e.g.
#TODO:  some shorter-hand way of checking values for NR?  an is_NR? added to every field?  
# perhaps any_nr?(*values)?   most reports do important checking logic

#partial _products_by_type_header
%tr.product_types
  %th
  -for type,products in products.group_by(&:product_type)
    %th {:colspan => products.size}
      = t(['product_types',type.code])   #TODO: needs an optional code addition for Supplies, indicating doses.  (or, rearrange layout/translation)
%tr.products
  %th
  -for product in products  #ordered by type and position
    %th= t(product.code)




#Reports:

###Data Completeness
complete = hcvs.select{|hcv| hcv.checkState == 'complete'}.size 
#row:  pct of hcs  (not hcvs!)
%tr
  %th= t.(reports.data_completeness)
  %td #{complete} / #{hcs.size} = #{to_pct(complete, hcs.size)}   

###Stockouts
# stockouts are from "existing" count only.  
# stockout present for product on a visit if ANY package has non-NR,  and NO package has >0
# (if all packages are NR, it does not count as a stockout)

stockouts_per_product={}
hcvs_visited.each do |hcv|
  products.each |p|
    stockouts_per_product[p] ||= 0
    counts = p.packages.map {|package| hcv.{epi|rdt}_inventory-{package}-existing
    end
    if counts.reject{|e| e == "NR"}.present? && counts.select{|e| e.to_i >0}.empty?
      stockouts_per_product[p] += 1
    end
  end
end
# rows:  pcts by product, with group labels
=products_by_type_header
%tr.stockouts
  %th= t('reports.stockout_label')
  -for product in products #ordered by type and position
    %td= to_pct(stockouts_per_product[p], hcvs_visited.size)




###Stock Card Usage
# currently labeled RDT stock cards, but those are the only cards right now.
stock_card_usage = {}
questions = %w(present used_correctly)
hcvs_visited.each do |hcv|
  stock_cards.each do |sc|
    stock_card_usage[sc] ||= {}
    questions.each do |question|
      stock_card_usage[sc][question] ||= 0
      stock_card_usage[sc][question] += 1 if hcv.stock_cards-{sc}-{question} == true
    end
  end
end

#rows:  pcts by card and question
%tr.stock_cards
  %th
  -for card in stock_cards
    %th= t(card.code)
- for question in questions
  %tr.usage.#{question}
    %th=t(['reports.stock_cards', question])
    -for card in stock_cards
      %td= to_pct(stock_card_usage[card][question], hcvs_visited.size)


###Supplies Delivered & Used
#NOTE:  this report requires an additional config:  
#  product.tally_codes, which list the tally attributes, e.g. 
# child_vac_tally.bcg.mb0_11, child_vac_tally.bcg.hc0_11, etc.
#  (could be a hard list in Product, or perhaps there's a pattern-based approach?)
#  syringes will also map to several vac tallies


#note this is in units (doses / kits / syringes)
unit_counts = {}
products.each do |product|
  unit_counts[product] = {:used=>0,:delivered=>0}
  hcvs_visited.each do |hcv|
    product.packages.each do |package|
      unit_counts[product][:delivered] += hcv.{epi|rdt}_inventory.{package}.delivered #NRs not allowed
    end
    product.tally_codes.each do |code| 
      unit_counts[product][:used] +=  hcv[code].to_i  #NRs count as 0 
    end
  end
end 
#special case:  safety box.tally_codes will = all syringe tallies = all vac tallies, but 
# estimated to only need 1 per 150 syringes
unit_counts['safetybox'][:used] /= 150  


#rows:  product grouping matches the stock out report, instead of the slightly differing current Supplies report
#  We should sell this as consistency, and change later upon request
= product_by_type_header
%tr.units_delivered
  %th= t(reports.supplies.delivered)
  -for product in products
    %td= unit_counts[product][:delivered]
%tr.units_used
  %th= t(reports.supplies.used)
  -for product in products
    %td= unit_counts[product][:used] unless product == 'gas'  #no use tallies for gas => no gas.tally_codes and no display



### Fridge problems 
#just count fridges and "functioning correctly" fridges
fridges_reported = 0
fridges_working = 0
hcvs_visited.each do |hcv|
  hcv.refrigerators.each do |fridge|
    next if fridge.running.nil? or fridge.running == 'unknown'
    fridges_reported += 1
    fridges_working += 1 if fridge.running == 'Yes'
  end
end
#row:    again, I'm suggesting a small format change to match another report -- data completeness 
%tr
  %th= t.(reports.fridge_problems )
  %td #{fridges_working} / #{fridges_reported} = #{to_pct(fridges_working, fridges_reported)}


### Visited Health Units
# no extra calc!
#row:  slight format change
%tr
  %th=t(reports.visited.hc_count)
  %th=t(reports.visited.hc_reported)
  %th=t(reports.visited.hc_visited)
  %th=t(reports.visited.pct_visited)
%tr
  %td= hcs.size
  %td= hcvs.size
  %td= hcvs_visited.size
  %td= to_pct(hcvs_visited.size, hcvs.size)
  

###Delivery Interval
# this assumes each hcv carries forward a last_visited_date, 
# essentially a cache so we don't have to access unlimited previous months
target_interval = 33  #hard code?
total = 0
target_count = 0
min = nil
max = nil
hcvs_visited.each do |hcv|
  days = (hcv.visit_date - hcv.last_visited_date)  #must be in days
  min = days if min.nil? || days < min
  max = days if max.nil? || days > max
  total += days
  target_count += 1 if days <= target_interval
end
visit_count = hcvs_visited.size
#row:
%tr
  %th
  %th= t(reports.delivery_interval.avg)
  %th= t(reports.delivery_interval.min)
  %th= t(reports.delivery_interval.max)
  %th= t(reports.delivery_interval.visit_count)
  %th= t(reports.delivery_interval.target_count)
  %th= t(reports.delivery_interval.target_pct)
%tr
  %th= t(reports.delivery_interval.interval)
  %td= (total / hcvs_visited.size).to_i
  %td= min
  %td= max
  %td= hcvs_visited.size
  %td= target_count
  %td= to_pct(target_count, hcvs_visited.size)


### Full Delivery
# NR logic:   if all packages have NR existing, that product/HC combination is ignored
# (delivered cannot be NR)
# ISAs assumed to be in units (doses/kits/syringes) 
full_deliveries = {}
hcvs_visited.each do |hcv|
  products.each do |product|
    full_deliveries[product] ||= 0
    final_stock = nil
    delivered = product.packages.each do |package|
      if hcv.epi_inventory[package.code].existing != "NR" 
        final_stock ||= 0   #now this product-HC combo counts  (how best to do this in js?)
        final_stock += hcv.epi_inventory[package.code].existing  * package.units
        final_stock += hcv.epi_inventory[package.code].delivered * package.units
      end
    end
    if final_stock.present?  && final_stock > hcv.health_center.ideals[product]  # ISAs assumed to be in units (doses/kits/syringes) 
      full_deliveries[product] += 1
    end
  end
end     
#rows:
=products_by_type_header
%tr.full_delivery
  %th= t(reports.full_delivery.pct_full)
  -for product in products
    %td= to_pct(full_deliveries[product], hcvs_visited.size)

### Wastage
# Important terminology notes.  This is based on the Ministry form and practice:
# 'received' = our 'delivered'   (form is from point of view of the HC)
#  'distributed' = actually given in vaccines (NOT our delivered).  YES this duplicates (and often doesn't match) vaccine tallies.   
#  'consumed' (my term)  = total amount gone from HC  = first_of_month + received - end_of_month
#  'loss' is unclear in exact definition, but it is ignored for wastage.    Some flavor of wastage, presumably.

#any NR used in calculations means that product-hc combo is ignored
vaccine_products = products_by_type('vaccine')
wastages = {}
hcvs.each do |hcv|  #note:  not just visiteds
  vaccine_products.each do |vaccine|
    wastages[vaccine] ||= {:consumed=>0, :distributed=>0}  
    epi_stock = hcv.epi_stock[vaccine]
    unless [epi_stock.first_of_month, epi_stock.received, epi_stock.distributed, epi_stock.end_of_month].include?('NR')
      wastages[vaccine][:consumed] += (epi_stock.first_of_month + epi_stock.received - epi_stock.end_of_month)
      wastages[vaccine][:distributed] += epi_stock.distributed
    end
  end
end
#row:
%tr.vaccines
  %th
  -for vaccine in vaccine_products
    %th= t(vaccine.code)
%tr.wastage_rates
  %td= t(reports.wastage.wastage_rates)
  -for vaccine in vaccine_products
    %td= to_pct(wastages[vaccine][:distributed],wastages[vaccine][:consumed])
%tr.wastage_targets
  %td= t(reports.wastage.wastage_targets)
  -for vaccine in vaccine_products
    %td < #{vaccine.wastage_target} %
    



### RDT Results
rdt_results = {}
rdt_products = products_by_type('rdt')
hcvs_visited.each do |hcv|
  rdt_products.each do |rdt|
    rdt_results[rdt] ||= {:total=>0, :positive=>0}
    total = hcv.rdt_stock[rdt].total
    positive = hcv.rdt_stock[rdt].positive
    unless total.nil? || total == 'NR' || positive.nil? || positive == 'NR'
      rdt_results[rdt][total] += total
      rdt_results[rdt][positive] += positive
    end
  end
end
#row:
%tr.rdts
  %th= t(reports.rdt_results.results)
  -for rdt in rdt_products
    %th= t(rdt.code)
%tr.total
  %th= t(reports.rdt_results.total)
  -for rdt in rdt_products
    %td= rdt_results[rdt][:total]
%tr.positive
  %th= t(reports.rdt_results.positive)
  -for rdt in rdt_products
    %td= rdt_results[rdt][:positive]
%tr.percentage
  %th= t(reports.rdt_results.percentage)
  -for rdt in rdt_products
    %td= to_pct(rdt_results[rdt][:positive], rdt_results[rdt][:total])

