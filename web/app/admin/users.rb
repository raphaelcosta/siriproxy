ActiveAdmin.register User do
  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :speech_id
    default_actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :speech_id
      f.input :assistant_id
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

  member_action :initial_token, :method => :put do
    user = User.find(params[:id])
    user.generate_initial_token
    user.save
    redirect_to :action => :show, :notice => "Token created!"
  end


end
