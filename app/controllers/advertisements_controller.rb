class AdvertisementsController < ApplicationController

	def new
  	@ad = Advertisement.new
  end

  def create
  	@ad = Advertisement.new(advertisement_params)
    if @ad.save
    	flash[:notice] = "successfully created."
    	redirect_to advertisements_path
    else
    	flash[:error] = "something went wrong pleade try again."
      redirect_to new_advertisement_path
    end
  end

  def index
  	@view_ads = Advertisement.ads
  	@ads = Advertisement.all
  end

  def destroy
  	ad = Advertisement.find(params[:id])
  	ad.destroy
  	redirect_to advertisements_path
  end

  private

  def advertisement_params
  	params.require(:advertisement).permit(:size, :price)
  end

end
