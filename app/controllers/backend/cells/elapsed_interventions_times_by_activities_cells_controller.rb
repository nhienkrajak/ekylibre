class Backend::Cells::ElapsedInterventionsTimesByActivitiesCellsController < Backend::Cells::BaseController

  def show
    if params[:campaign_id] and campaign = Campaign.find(params[:campaign_id])
      @campaign = campaign
    else
      @campaign = Campaign.currents.last
    end
  end

end
