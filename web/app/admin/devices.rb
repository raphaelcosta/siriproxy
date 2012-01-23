#encoding: utf-8 
ActiveAdmin.register Device do
  menu :label => "Dispositivos"

  scope :all, :default => true
  scope :without_user do |devices|
    devices.where(:user_id => nil)
  end


  index do
    column :speechid
    column :assistantid
    column :token
    column :user do |v| v.user ? v.user.name : "" end
    column :access_count
    column :updated_at
    default_actions
  end


  filter :token
  filter :user,  :as => :select,      :collection => User.order('name').all
  filter :speechid
  filter :assistantid


  form do |f|
    f.inputs "Detalhes do usuário" do
      f.input :user,  :as => :select,      :collection => User.order('name').all
      f.input :speechid
      f.input :assistantid
      f.input :token
    end
    f.buttons
  end


  member_action :initial_token, :method => :put do
    device = Device.find(params[:id])
    device.generate_token
    device.save
    redirect_to :action => :show, :notice => "Token created!"
  end  
end
