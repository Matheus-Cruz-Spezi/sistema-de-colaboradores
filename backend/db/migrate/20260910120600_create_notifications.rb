class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true

      t.string   :title,    null: false
      t.text     :body
      t.integer  :category, null: false, default: 0  # enum: info/success/warning/alert
      t.datetime :read_at

      # Registro relacionado (ex.: o Employee que sofreu alteração). Opcional.
      t.references :notifiable, polymorphic: true

      t.timestamps
    end

    add_index :notifications, %i[user_id read_at]
  end
end
