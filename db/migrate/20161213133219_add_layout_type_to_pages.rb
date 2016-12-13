class AddLayoutTypeToPages < ActiveRecord::Migration
  def up
    add_column :pages, :layout_type, :string
    change_column_default :pages, :layout_type, 'default'
    change_column_null :pages, :layout_type, 'default'
    execute <<-SQL
          UPDATE pages
            SET layout_type = 'default'
    SQL
  end

  def down
    remove_column :pages, :layout_type
  end
end
