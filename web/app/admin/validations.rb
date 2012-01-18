#encoding: utf-8
ActiveAdmin.register Validation do
  index do
    column :key do |v| v.key[0..40] end
    column :expired do |v| v.expired? ? 'Sim' : "Não" end
    column :user do |v| v.device.user ? v.device.user.name : "" end
    column :created_at
    default_actions
  end

end
