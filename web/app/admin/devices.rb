#encoding: utf-8 
ActiveAdmin.register Device do

  scope :all, :default => true
  scope :without_user do |devices|
    devices.where(:user => nil)
  end


  index do
    column :key do |v| v.key[0..40] end
    column :expired do |v| v.expired? ? 'Sim' : "Não" end
    column :user do |v| v.device.user? ? v.device.user.name : "" end
    column :created_at
    default_actions
  end


  filter :token
  filter :user


  member_action :initial_token, :method => :put do
    device = Device.find(params[:id])
    device.generate_token
    device.save
    redirect_to :action => :show, :notice => "Token created!"
  end  
end
