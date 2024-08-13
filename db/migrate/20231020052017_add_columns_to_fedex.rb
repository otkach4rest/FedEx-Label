class AddColumnsToFedex < ActiveRecord::Migration[7.0]
  def change
    add_column :fedex_labels, :image, :string
    add_column :fedex_labels, :options, :json
    add_column :fedex_labels, :response_details, :json
  end
end
