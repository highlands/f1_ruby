class CreateF1Users < ActiveRecord::Migration
  def change
    create_table :f1_users do |t|
      t.string :username
      t.string :token
      t.string :secret
      t.string :url
      t.string :last_sign_in_ip
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
