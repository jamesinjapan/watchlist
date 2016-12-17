class ChangeColumnAdultFlag < ActiveRecord::Migration
  def change
    remove_column :users, :adult_flag
    add_column :users, :adult_flag, :boolean, :default => false
  end
end
