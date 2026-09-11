class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      # Login opcional: nem todo funcionário acessa o sistema.
      t.references :user, foreign_key: true, index: { unique: true }
      t.references :department, null: false, foreign_key: true

      t.string  :full_name,       null: false
      t.string  :email,           null: false
      t.string  :document_number, null: false          # CPF
      t.string  :job_title,       null: false          # cargo
      t.string  :phone

      t.integer :employment_status, null: false, default: 0  # enum: active/on_leave/terminated
      t.date    :hired_on,          null: false
      t.date    :terminated_on
      t.date    :birth_date
      t.decimal :salary, precision: 12, scale: 2

      t.timestamps
    end

    add_index :employees, :email,             unique: true
    add_index :employees, :document_number,   unique: true
    add_index :employees, :employment_status
    add_index :employees, :full_name
  end
end
