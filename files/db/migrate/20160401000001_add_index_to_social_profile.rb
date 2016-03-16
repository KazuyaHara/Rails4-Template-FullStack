class AddIndexToSocialProfile < ActiveRecord::Migration
  def change
    add_index :social_profiles, [:provider, :uid], unique: true
  end
end
