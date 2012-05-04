class ConvertIdealStockToDoses < ActiveRecord::Migration
  def up
    add_column :ideal_stock_amounts, :product_id, :integer

    # drop ideal stock amounts for non-primary packages
    pkg_ids = Package.scoped.reject(&:primary?).map(&:id)
    IdealStockAmount.where(:package_id => pkg_ids).delete_all

    packages = Package.all.group_by(&:id)
    IdealStockAmount.scoped.each do |isa|
      package = packages[isa.package_id].first
      isa.update_attributes({
        :product_id => package.product_id,
        :quantity   => isa.quantity * package.quantity,
      })
    end

    remove_column :ideal_stock_amounts, :package_id
  end

  def down
    add_column :ideal_stock_amounts, :package_id, :integer

    pkgs_by_product = Package.primary.group_by(&:product_id)
    IdealStockAmount.scoped.each do |isa|
      package = pkgs_by_product[isa.product_id].first
      isa.update_attributes({
        :package_id => package.id,
        :quantity   => (isa.quantity.to_f / package.quantity).round,
      })
    end

    remove_column :ideal_stock_amounts, :product_id
  end
end
