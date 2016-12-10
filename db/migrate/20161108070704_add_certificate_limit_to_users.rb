class AddCertificateLimitToUsers < ActiveRecord::Migration
  def change
    add_column :users, :certificate_limit, :string
  end
end
