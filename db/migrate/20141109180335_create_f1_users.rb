class CreateF1Users < ActiveRecord::Migration
  enable_extension 'hstore' unless extension_enabled?('hstore')
  def change
    create_table :f1_users do |t|
      t.string :username
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :token
      t.string :secret
      t.string :url
      t.string :type
      t.data :hstore
      t.string :last_sign_in_ip
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
