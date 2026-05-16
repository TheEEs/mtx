class RoomsController < ApplicationController
  allow_unauthenticated_access only: [:index, :auth]
  skip_before_action :verify_authenticity_token, only: [:auth]
  before_action :set_room, only: %i[ show edit update destroy toggle_stream ]
  around_action :set_timezone, only: %i[ auth update create edit ]
  # GET /rooms or /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1 or /rooms/1.json
  def show
    @whepURL = request.base_url
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms/auth

  def auth
    room_id = params[:path]
    room = Room.find(room_id)
    token = params[:token]
    payload, header = JWT.decode token, Rails.application.credentials.key, true, { algorithm: 'HS512' }
    if token != room.jwt || room.blocked
      raise "unauthorized" 
    end
    if room.update(stream_id: params[:id])
      render plain: "OK", layout: false, status: :ok
    else 
      raise "unauthorized"
    end
  rescue 
    render plain: "Error", layout: false, status: :unauthorized
  end

  # POST /rooms or /rooms.json
  def create
    @room = Room.new(room_params)
    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: I18n.t("flash.success.created", model: Room.model_name.human)}
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1 or /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: I18n.t("flash.success.updated", model: Room.model_name.human), status: :see_other }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1 or /rooms/1.json
  def destroy
    @room.destroy!

    respond_to do |format|
      format.html { redirect_to rooms_path, notice: I18n.t("flash.success.deleted", model: Room.model_name.human), status: :see_other }
      format.json { head :no_content }
    end
  end

  # DELETE /room/1/stream
  def toggle_stream
    respond_to do |format|
      @room.blocked = !@room.blocked
      if @room.save!
        format.html { render plain: "OK", layout: false, status: :ok }
        format.json { head :no_content }
        format.turbo_stream
        res = HTTParty.post(
          "http://mediamtx:7498/v3/webrtcsessions/kick/#{@room.stream_id}"
        )
        raise "Cannot kickout stream" unless res.code == 200
      else
        format.html { render :show, status: :unprocessable_entity}
        format.json {render json: {error: :unprocessable_entity}, status: :unprocessable_entity}
      end
      rescue 
        format.html { render :show, status: :unprocessable_entity}
        format.json {render json: {error: :unprocessable_entity}, status: :unprocessable_entity}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def room_params
      params.expect(room: [:name, :owner, :description, :valid_from, :valid_to, :timezone])
    end

    def set_timezone
      Time.use_zone(@room&.timezone || params.dig(:room,:timezone) || "UTC") do 
        yield 
      end
    end
end
