class AlterApnGroups < ActiveRecord::Migration # :nodoc:

  def self.up
    add_column :apn_groups, :app_id, :integer
    add_column :apn_devices, :app_id, :integer
    add_column :apn_devices, :state, :boolean
  end

  def self.down
    remove_column :apn_groups, :app_id
  end

end