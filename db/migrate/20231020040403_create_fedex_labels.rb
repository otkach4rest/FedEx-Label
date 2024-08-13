class CreateFedexLabels < ActiveRecord::Migration[7.0]
  def change
    create_table :fedex_labels do |t|

      t.timestamps
    end
  end
end
