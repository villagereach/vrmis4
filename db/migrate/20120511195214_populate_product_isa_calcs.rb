class PopulateProductIsaCalcs < ActiveRecord::Migration
  def up
    isa_calcs = {}
    isa_calcs['safetybox'] = <<-END.strip_heredoc
      var quantity = (isa.syringe5ml + isa.syringe05ml + isa.syringe005ml) / 150;
      isa.safetybox = Math.ceil(quantity);
    END
    isa_calcs['polio'] = <<-END.strip_heredoc
        var quantity = population * 0.039 * 4 * 1.1 / 12 * 1.25
        isa.polio = Math.ceil(quantity);
    END
    isa_calcs['penta'] = <<-END.strip_heredoc
        var quantity = population * 0.039 * 3 * 1.1 / 12 * 1.25;
        isa.penta = Math.ceil(quantity);
    END
    isa_calcs['tetanus'] = <<-END.strip_heredoc
        var quantity = population * 0.05 * 2 * 1.1 / 12 * 1.25;
        isa.tetanus = Math.ceil(quantity);
    END
    isa_calcs['bcg'] = <<-END.strip_heredoc
        var quantity = population * 0.04 * 1.5 / 12 * 1.25;
        isa.bcg = (quantity > 100) ? Math.ceil(quantity) : 100;
    END
    isa_calcs['measles'] = <<-END.strip_heredoc
        var quantity = population * 0.039 * 1.3 / 12 * 1.25;
        isa.measles = (quantity > 50) ? Math.ceil(quantity) : 50;
    END
    isa_calcs['syringe5ml'] = <<-END.strip_heredoc
        var quantity = ((isa.bcg / 20) + (isa.measles / 10)) * 1.11
        isa.syringe5ml = Math.ceil(quantity / 10) * 10;
    END
    isa_calcs['syringe05ml'] = <<-END.strip_heredoc
        var quantity = (isa.penta + isa.measles + isa.tetanus) * 1.11;
        isa.syringe05ml = Math.ceil(quantity / 100) * 100;
    END
    isa_calcs['syringe005ml'] = <<-END.strip_heredoc
        var quantity = isa.bcg * 1.11;
        isa.syringe005ml = Math.ceil(quantity / 10) * 10;
    END

    Product.scoped.each {|p| p.update_attributes(:isa_calc => isa_calcs[p.code]) }
  end

  def down
    Product.scoped.each {|p| p.update_attributes(:isa_calc => nil) }
  end
end
