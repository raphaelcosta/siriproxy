class ProspectsController < ApplicationController
  respond_to :js

  def create
    @prospect = Prospect.new(params[:prospect])
    @prospect.save
    respond_with @prospect
  end

end
