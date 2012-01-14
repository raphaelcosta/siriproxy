#encoding: utf-8
ActiveAdmin.register Validation do
  index do
    column :id
    column :key do |v| v.key[0..40] end
    column :expired do |v| v.expired? ? 'Sim' : "Não" end
    default_actions
  end

end
