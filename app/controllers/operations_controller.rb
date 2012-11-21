class OperationsController < ApplicationController
  # GET /operations.json
  def index
    @operations = Operation.all
    render json: @operations
  end
end
