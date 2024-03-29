#encoding: utf-8
ActiveAdmin.register User do
  menu :label => "Usuários"

  index do
    column :id
    column :name
    column :email
    column :sign_in_count
    column :seeder do |u| u.seeder? ? "Sim" : "Não" end
    column :devices_count do |u| u.devices.count end
    column :enviar_sms do |u|  link_to('Enviar SMS', [ :sms,:admin,u]) if u.seeder? end
    default_actions
  end

  filter :name
  filter :email
  filter :seeder, :as => :select
  filter :created_at

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

    
  end

  member_action :sms, :method => :get do
    user = User.find(params[:id])
    user.send_sms
    redirect_to :action => :show, :notice => "SMS de lembrete enviada!"
  end



end
