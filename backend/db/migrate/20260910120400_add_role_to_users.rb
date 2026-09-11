class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    # A tabela users está vazia neste ponto; role_id pode entrar como NOT NULL.
    add_reference :users, :role, null: false, foreign_key: true, index: true
  end
end
