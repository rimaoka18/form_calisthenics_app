class AddHeightToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :height, :integer
  end
end
