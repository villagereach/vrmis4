class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string   :locale
      t.string   :name
      t.text     :translations

      t.timestamps
    end

    add_index :languages, :locale
  end

end
