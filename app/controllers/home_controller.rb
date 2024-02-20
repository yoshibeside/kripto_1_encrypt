require 'string_helper'

class HomeController < ApplicationController
  include StringHelper

  def index
    # Check if the request method is POST
    if request.post?
      Rails.logger.debug "The request is going through the POST method."
    else
      Rails.logger.debug "The request is not going through the POST method."
    end
    
    @show_element = false
  end

  def process_form
    # Logic to process the form submission
    # For example, you might update @show_element based on the selected option
    # Rails.logger.debug "Form parameters: #{params.inspect}"
    Rails.logger.debug "First drop down #{params[:dropdown]}"
    Rails.logger.debug "First drop down #{params[:dropdown_cipher]}"
    Rails.logger.debug "First drop down #{params[:key]}"
    Rails.logger.debug "First drop down #{params[:input_text]}"

    @trimed = StringHelper.trim_string(params[:input_text])

    Rails.logger.debug "First #{@trimed}"
    if params[:option] == 'option1'
      @show_element = 'option1'
    else
      @show_element = 'option2'
    end
    
    # Redirect to another location after processing the form data
    redirect_to root_path
  end
end