module Pipette
  class CollectingUnitsController < ApplicationController
    before_action :set_collecting_unit, only: %i[show edit update]

    # GET /collecting_units
    def index
      @collecting_units = CollectingUnit.all
    end

    # GET /collecting_units/1
    def show
    end

    # GET /collecting_units/new
    def new
      @collecting_unit = CollectingUnit.new
    end

    # GET /collecting_units/1/edit
    def edit
    end

    # POST /collecting_units
    def create
      @collecting_unit = CollectingUnit.new(collecting_unit_params)

      if @collecting_unit.save
        redirect_to collecting_units_path, notice: "Collecting unit was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /collecting_units/1
    def update
      if @collecting_unit.update(collecting_unit_params)
        redirect_to collecting_units_path notice: "Collecting unit was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_collecting_unit
      @collecting_unit = CollectingUnit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def collecting_unit_params
      params.require(:collecting_unit).permit(:collecting_unit)
    end
  end
end
