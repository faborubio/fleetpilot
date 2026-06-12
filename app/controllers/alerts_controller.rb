class AlertsController < ApplicationController
  def index
    authorize Alert
    @alerts = current_account.alerts.active.by_urgency.includes(:alertable)
  end

  def destroy
    @alert = current_account.alerts.find(params[:id])
    authorize @alert
    @alert.dismiss!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to alerts_path, notice: "Alert dismissed." }
    end
  end
end
