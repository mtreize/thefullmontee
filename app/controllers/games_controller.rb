class GamesController < ApplicationController
  include ApplicationHelper
  
  before_action :set_game, only: [:show, :edit, :update, :destroy]

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
    # @game.generate_title
    # @game.generate_title if @game.title.blank?
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def edit_round
    
    @game=Game.find(params[:id])
    @round=@game.rounds.where(:number=>params[:round_number]).first
    @players=@game.players
    pts={}
    @players_score_for_this_round={}
    @players.each do |p|
      pts[p.id]=@round.current_total_for_player(p).to_i
      @players_score_for_this_round[p.id]=Score.where(:player=>p, :round=>@round).try(:first).try(:value)
    end
    @players_total_scores=pts.sort_by{ |k,v| v }
    
  end
  def save_round
    @game=Game.find(params[:id])
    @round=@game.rounds.where(:number=>params[:round_number]).first
    @players=@game.players
    
    params[:players_scores].each do |pid,value|
      Score.where(:player_id=>pid, :round=>@round).destroy_all
      Score.create(:value=>value, :player_id=>pid, :round=>@round)
      
    end
    if (@round.number)+1<=@game.nb_rounds
      new_round=Round.create(:game=>@game, :number=>(@round.number)+1)
      redirect_to game_edit_round_path(@game.id, new_round.number)
    else
      redirect_to game_recap_path(@game.id)
    end
  end
  
  def recap
    @game=Game.find(params[:id])
    @curves={}
    @chart_data = {
      labels: @game.rounds.pluck(:number).insert(0,0),
      datasets: []
      }
    @game.players.each_with_index do |p,index|
      player_curve=[]
      player_curve<< 0
      @curves[p.name]=[]
      total=0
      @game.rounds.each do |r|
        a=Score.where(:round=>r, :player=>p).try(:first).try(:value) ||0
        player_curve<<(total+a)
        total=total+a
      end
      @curves[p.name] = player_curve
      c={
          fill:false,
          borderColor: chart_colors[index],
          backgroundColor: chart_colors[index],
          lineTension: 0.25,
          label: p.name,
          data: player_curve,
          
        }
      @chart_data[:datasets].push c
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:location)
    end
end
