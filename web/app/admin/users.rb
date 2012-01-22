#encoding: utf-8
ActiveAdmin.register User do
  index do
    column :name
    column :email
    column :sign_in_count
    column :seeder do |u| u.seeder? ? "Sim" : "Não" end
    column :devices_count do |u| u.devices.count end
    column :send_sms do |u|  u.send_sms end
    default_actions
  end

  filter :name
  filter :email
  filter :seeder

  form do |f|
    f.inputs "Detalhes do usuário" do
      f.input :name
      f.input :phone
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :seeder
    end
    f.buttons
  end

  controller do
    before_filter :password , :only => [:update]
    def password
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
    end

    member_action :sms, :method => :get do
      user = User.find(params[:id])
      user.send_sms
      redirect_to :action => :show, :notice => "SMS de lembrete enviada!"
    end
  end




end
