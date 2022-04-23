class AddColumnSurveyToServiceDesk < ActiveRecord::Migration[6.1]
  def change
    add_column :service_desks, :survey, :integer, null: true, default: 0
  end
end
