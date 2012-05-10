class AddVisitedAtToHcVisits < ActiveRecord::Migration
  def change
    add_column :hc_visits, :visited_at, :date
  end
end
