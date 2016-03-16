class AddDummyEmailToUser < ActiveRecord::Migration
  def change
    add_column :users, :dummy_email, :boolean, default: false
    add_index :users, :dummy_email
  end
end
