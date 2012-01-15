ActiveAdmin.register Device do
  member_action :initial_token, :method => :put do
    device = Device.find(params[:id])
    device.generate_token
    device.save
    redirect_to :action => :show, :notice => "Token created!"
  end  
end
