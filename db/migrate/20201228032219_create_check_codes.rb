class CreateCheckCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :check_codes do |t|
      t.string :code
      t.boolean :archived, default: false
      t.timestamps
    end
  end
end
