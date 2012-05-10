class Offline::ConfigSnapshotsController < OfflineController
  respond_to :json

  def index
    synced_at = DateTime.now

    since = DateTime.parse(params[:since]) if params[:since].present?

    province = Province.find_by_code(params[:province])
    snapshot = ConfigSnapshot.new(:province => province)

    if since.nil? || since < snapshot.latest_updated_at
      snapshot_json = snapshot.capture!
    end

    render :json => {
      'synced_at' => synced_at.utc.strftime('%Y-%m-%d %H:%M:%S'),
      'snapshots' => snapshot_json ? [snapshot_json] : [],
    }
  end

end
