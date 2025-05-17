class ChangeIssueStatusNameLimit < ActiveRecord::Migration[6.0]
  def up
    change_column :issue_statuses, :name, :string, limit: 60
  end

  def down
    change_column :issue_statuses, :name, :string, limit: 30
  end
end