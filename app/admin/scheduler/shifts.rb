ActiveAdmin.register Scheduler::Shift, namespace: 'scheduler_admin', as: 'Shift' do

  scope :all, default: true do |shifts|
    shifts.includes([:shift_group, :county]).order(:county_id, :shift_group_id, :ordinal)
  end

  index do
    column :shift_group, sortable: "scheduler_shift_groups.start_offset"
    column :county
    column :name
    column :abbrev
    column 'Spreadsheet', :spreadsheet_ordinal
    column :ordinal
    actions
  end

  form do |f|
    f.inputs 'Details'
    f.inputs 'Position and County' do

      f.input :positions, as: :check_boxes
      f.input :county
      f.input :shift_group
      f.actions
    end
  end

  controller do
    def resource_params
      request.get? ? [] : [params.require(:shift).permit(:name, :abbrev, :shift_group_id, :max_signups, :county_id, :ordinal, :spreadsheet_ordinal, :shift_begins, :shift_ends, :signups_frozen_before, :position_ids => [])]
    end
  end
end