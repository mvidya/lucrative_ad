class CreateAdvertisements < ActiveRecord::Migration[5.0]
  def change
    create_table :advertisements do |t|
      t.string :size
      t.integer :price
      t.timestamps
    end
  end
end
