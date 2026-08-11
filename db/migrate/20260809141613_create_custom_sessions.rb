class CreateCustomSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :custom_sessions do |t|
      t.string :cookie
      t.string :IP
      t.integer :login_count
      t.datetime :expire_time

      t.timestamps
    end
  end
end
