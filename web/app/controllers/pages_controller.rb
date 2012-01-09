class PagesController < ApplicationController
  def index
    @prospect = Prospect.new
  end

end
