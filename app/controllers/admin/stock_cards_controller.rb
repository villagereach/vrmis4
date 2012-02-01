class Admin::StockCardsController < AdminController
  respond_to :html, :xml, :json

  def index
    @stock_cards = StockCard.order(:code).page(params[:page])
    respond_with :admin, @stock_cards
  end

  def show
    @stock_card = StockCard.find(params[:id])
    respond_with :admin, @stock_card
  end

  def new
    @stock_card = StockCard.new
    respond_with :admin, @stock_card
  end

  def edit
    @stock_card = StockCard.find(params[:id])
    respond_with :admin, @stock_card
  end

  def create
    @stock_card = StockCard.new
    @stock_card.attributes = params[:stock_card]
    if @stock_card.save
      flash[:notice] = "StockCard created successfully."
    end

    respond_with :admin, @stock_card
  end

  def update
    @stock_card = StockCard.find(params[:id])
    if @stock_card.update_attributes(params[:stock_card])
      flash[:notice] = "StockCard updated successfully."
    end

    respond_with :admin, @stock_card
  end

  def destroy
    @stock_card = StockCard.find(params[:id])
    if @stock_card.destroy
      flash[:notice] = "StockCard destroyed successfully."
    end

    respond_with :admin, @stock_card
  end

end
