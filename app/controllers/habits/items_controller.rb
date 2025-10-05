class Habits::ItemsController < ApplicationController
  # GET /habits/items
  def index
    # List all habit items
  end

  # GET /habits/items/:id
  def show
    # Show a specific habit item
  end

  # GET /habits/items/new
  def new
    @habit_item = Habits::Item.new

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # POST /habits/items
  def create
    # Create a new habit item
  end

  # GET /habits/items/:id/edit
  def edit
    # Edit form for a habit item
  end

  # PATCH/PUT /habits/items/:id
  def update
    # Update a habit item
  end

  # DELETE /habits/items/:id
  def destroy
    # Delete a habit item
  end
end
