# Coluna opcional onde o PaperTrail guarda o diff (changeset) de cada update.
class AddObjectChangesToVersions < ActiveRecord::Migration[8.1]
  def change
    add_column :versions, :object_changes, :jsonb
  end
end
