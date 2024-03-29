#encoding: utf-8
ActiveAdmin.register Validation do
  menu :label => "Chaves do 4S",:parent => 'Usuários'

  scope :all, :default => true
  scope :active do |validations|
    validations.where(:expired => false)
  end

  index do
    column :key do |v| v.key[0..40] end
    column :expired do |v| v.expired? ? 'Sim' : "Não" end
    column :user do |v| v.device and v.device.user ? v.device.user.name : "" end
    column :created_at
    default_actions
  end

end
