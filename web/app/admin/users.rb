#encoding: utf-8
ActiveAdmin.register User do
  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    default_actions
  end

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




end
