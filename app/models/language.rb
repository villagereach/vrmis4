#encoding: utf-8
class Language < ActiveRecord::Base
  serialize :translations, Hash

  validates :locale, :presence => true, :uniqueness => true
  validates :name, :presence => true

  default_scope order(:locale)

  #console find-a-translation
  def pgrep(pat)
    translations.each{|k,v| rgrep(pat,k,v,nil) }
    nil
  end

  def rgrep(pat,key,val,prefix)
    newkey = [prefix,key].compact.join(".")
    if val.is_a? Hash 
      val.each {|k,v| rgrep(pat,k,v, newkey)}
    else
      puts "#{newkey}: #{val}" if val.to_s.match(pat)
    end
  end
  
      
  def self.locales
    @locales ||= Language.select(:locale).map(&:locale)
  end
  
  def self.add_stuff
    en=Language.where(:locale=>:en).first
    pt=Language.where(:locale=>:pt).first
    en.translations['tab_labels'] = {
      "visit-info" => "Visit",
      "refrigerators" => "Refrigerators",
      "epi-inventory" =>"EPI Inventory",
      "rdt-inventory" =>"RDT Inventory",
      "equipment-status" =>"Equipment",
      "stock-cards" =>"Stock Cards",
      "rdt-stock" =>"RDT Use",
      "epi-stock" =>"EPI Use",
      "full-vac-tally"  =>"Full",
      "child-vac-tally" => "Adults",
      "adult-vac-tally" => "Children",
      "observations" => "Observations"
    
    }
    en.translations["monthly_tasks"] = 'Monthly Tasks'
    pt.translations['tab_labels'] = {
      "visit-info" => "Visita",
      "refrigerators" => "Geladeiras",
      "epi-inventory" =>"Inventário do PAV",
      "rdt-inventory" =>"Inventário do Testes",
      "equipment-status" =>"Equipamentos",
      "stock-cards" =>"Cartão de Stock",
      "rdt-stock" =>"Uso do Testes",
      "epi-stock" =>"Uso do PAV",
      "full-vac-tally"  =>"Complemente",
      "child-vac-tally" => "Adultos",
      "adult-vac-tally" => "Crianças",
      "observations" => "Observações"
 
    }
    pt.translations["monthly_tasks"] = 'Tarefas Mensais'
    [en.save,pt.save]
  end
    
end
