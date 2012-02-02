class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :username
      t.string   :password_digest
      t.string   :name
      t.string   :language
      t.string   :timezone
      t.string   :role
      t.datetime :last_login

      t.timestamps
    end

    add_index :users, :username
  end

end
