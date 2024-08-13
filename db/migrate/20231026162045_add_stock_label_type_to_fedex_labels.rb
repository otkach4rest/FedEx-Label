class AddStockLabelTypeToFedexLabels < ActiveRecord::Migration[7.0]
  def change
    add_column :fedex_labels, :label_stock_type, :string
    add_column :fedex_labels, :service_type, :string
  end
end
