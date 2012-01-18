#encoding: utf-8 
ActiveAdmin.register Device do

  scope :all, :default => true
  scope :without_user do |devices|
    devices.where(:user_id => nil)
  end


  index do
    column :speechid
    column :assistantid
    column :token
    column :user do |v| v.device.user? ? v.device.user.name : "" end
    column :created_at
    column :updated_at
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
