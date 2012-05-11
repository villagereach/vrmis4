class PopulateProductIsaCalcs < ActiveRecord::Migration
  def up
    Product.find_by_code('safetybox').update_attributes(
      :isa_calc => <<-END.strip_heredoc
        var quantity = (isa.syringe5ml + isa.syringe05ml + isa.syringe005ml) / 150;
        isa.safetybox = Math.ceil(quantity);
      END
    )

    Product.find_by_code('polio').update_attributes(
      :isa_calc => <<-END.strip_heredoc
        var quantity = population * 0.039 * 4 * 1.1 / 12 * 1.25
        isa.polio = Math.ceil(quantity);
      END
    )

    Product.find_by_code('penta').update_attributes(
      :isa_calc => <<-END.strip_heredoc
        var quantity = population * 0.039 * 3 * 1.1 / 12 * 1.25;
        isa.penta = Math.ceil(quantity);
      END
    )

    Product.find_by_code('tetanus').update_attributes(
      :isa_calc => <<-END.strip_heredoc
        var quantity = population * 0.05 * 2 * 1.1 / 12 * 1.25;
        isa.tetanus = Math.ceil(quantity);
      END
    )

    Product.find_by_code('bcg').update_attributes(
      :isa_calc => <<-END.strip_heredoc
        var quantity = population * 0.04 * 1.5 / 12 * 1.25;
        isa.bcg = (quantity > 100) ? Math.ceil(quantity) : 100;
      END
    )

    Product.find_by_code('measles').update_attributes(
      :isa_calc => <<-END.strip_heredoc
        var quantity = population * 0.039 * 1.3 / 12 * 1.25;
        isa.measles = (quantity > 50) ? Math.ceil(quantity) : 50;
      END
    )

    Product.find_by_code('syringe5ml').update_attributes(
      :isa_calc => <<-END.strip_heredoc
        var quantity = ((isa.bcg / 20) + (isa.measles / 10)) * 1.11
        isa.syringe5ml = Math.ceil(quantity / 10) * 10;
      END
    )

    Product.find_by_code('syringe05ml').update_attributes(
      :isa_calc => <<-END.strip_heredoc
        var quantity = (isa.penta + isa.measles + isa.tetanus) * 1.11;
        isa.syringe05ml = Math.ceil(quantity / 100) * 100;
      END
    )

    Product.find_by_code('syringe005ml').update_attributes(
      :isa_calc => <<-END.strip_heredoc
        var quantity = isa.bcg * 1.11;
        isa.syringe005ml = Math.ceil(quantity / 10) * 10;
      END
    )
  end

  def down
  end
end
