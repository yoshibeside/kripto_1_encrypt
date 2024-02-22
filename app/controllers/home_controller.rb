require 'string_helper'
require 'cipher_helper'

class HomeController < ApplicationController
  include StringHelper
  include CipherHelper

  def index
    # Check if the request method is POST
    Rails.logger.debug "Form parameters: #{params.inspect}"
    if request.post?
      Rails.logger.debug "The request is going through the POST method."
    else
      Rails.logger.debug "The request is not going through the POST method."
    end
  end


  def process_form
    # Logic to process the form submission
    # For example, you might update @show_element based on the selected option
    # Rails.logger.debug "Form parameters: #{params.inspect}"
    Rails.logger.debug "First drop down #{params[:dropdown]}"
    Rails.logger.debug "First drop down #{params[:dropdown_cipher]}"
    Rails.logger.debug "First drop down #{params[:key]}"
    Rails.logger.debug "First drop down #{params[:input_text]}"

    plaintext = "default"

    # validating input
    if (params[:input_text] == "" && params[:dropdown] == "text")
      flash[:result] = "Text input cannot be empty"
      redirect_back(fallback_location: root_path)
      return
    end
    if (params[:key] == "")
      flash[:result] = "Key cannot be empty"
      redirect_back(fallback_location: root_path)
      return
    end

    # Processing Input
    if (params[:dropdown] == "text")
      if params[:file_option] === "text"
        plaintext = params[:input_text]
      else 
        plaintext = Base64.decode64(params[:input_text])
      end

    elsif params[:dropdown] == "textfile" && params[:file_text]
      file_content = File.read(params[:file_text].tempfile)
      if params[:file_option] === "text"
        plaintext = file_content
      else 
        plaintext = Base64.decode64(file_content)
      end
    else
      redirect_back(fallback_location: root_path)
      return
    end

    trimed = StringHelper.trim_string(plaintext)
    Rails.logger.debug "result trim #{trimed}"
    key = StringHelper.trim_string(params[:key])

    if params[:dropdown_cipher] == 'vig_cipher' && params[:input_text] && params[:encrypt_button]
      encrypted = CipherHelper.enc_vig_cipher_26(trimed, key)
      flash[:show_element] = true
      flash[:result] = Base64.encode64(encrypted)
      flash[:binary_data] = encrypted.unpack("B*").first
      flash[:text_data] = Base64.encode64(encrypted)

    elsif params[:dropdown_cipher] == 'vig_cipher' && params[:input_text] && params[:decrypt_button]
      decrypted = CipherHelper.dec_vig_cipher_26(trimed, key)
      flash[:show_element] = true
      flash[:result] = decrypted
      flash[:binary_data]
      
    elsif params[:dropdown_cipher] == 'auto_vig_cipher' && params[:input_text] && params[:encrypt_button]
      encrypted = CipherHelper.enc_autokey_vigenere_cipher(trimed, key)
      flash[:show_element] = true
      flash[:result] = Base64.encode64(encrypted)

    elsif params[:dropdown_cipher] == 'auto_vig_cipher' && params[:input_text] && params[:decrypt_button]
      decrypted = CipherHelper.dec_autokey_vigenere_cipher(trimed, key)
      flash[:show_element] = true
      flash[:result] = decrypted

    elsif params[:dropdown_cipher] == 'ext_vig_cipher' && params[:input_text] && params[:encrypt_button]
      encrypted = CipherHelper.enc_extended_vigenere_cipher(plaintext, params[:key])
      flash[:show_element] = true
      flash[:result] = Base64.encode64(encrypted)

    elsif params[:dropdown_cipher] == 'ext_vig_cipher' && params[:input_text] && params[:decrypt_button]
      decrypted = CipherHelper.dec_extended_vigenere_cipher(plaintext, params[:key])
      flash[:show_element] = true
      flash[:result] = decrypted

    elsif params[:dropdown_cipher] == 'playfair_cipher' && params[:input_text] && params[:encrypt_button]
      mod_text = StringHelper.prepare_playfair_text(trimed)
      encrypted = CipherHelper.enc_playfair_cipher(mod_text, params[:key])
      flash[:show_element] = true
      flash[:result] = Base64.encode64(encrypted)

    elsif params[:dropdown_cipher] == 'playfair_cipher' && params[:input_text] && params[:decrypt_button]
      decrypted = CipherHelper.dec_playfair_cipher(trimed, params[:key])
      flash[:show_element] = true
      flash[:result] = decrypted

    elsif params[:dropdown_cipher] == 'affine_cipher' && params[:input_text] && params[:encrypt_button] && params[:m] && params[:b]
      encrypted = CipherHelper.enc_affine_cipiher(trimed, params[:m].to_i, params[:b].to_i)
      flash[:show_element] = true
      flash[:result] = Base64.encode64(encrypted)

    elsif params[:dropdown_cipher] == 'affine_cipher' && params[:input_text] && params[:decrypt_button] && params[:m] && params[:b]
      decrypted = CipherHelper.dec_affine_cipher(trimed, params[:m].to_i,  params[:b].to_i)
      flash[:show_element] = true
      flash[:result] = decrypted

    elsif params[:dropdown_cipher] == 'hill_cipher' && params[:input_text] && params[:encrypt_button]
      block_size = params[:block_size].to_i
      matrix = StringHelper.prepare_key_hill_cipher(params, block_size)
      encrypted = CipherHelper.enc_hill_cipher(trimed, block_size, matrix)
      flash[:show_element] = true
      flash[:result] = Base64.encode64(encrypted)

    elsif params[:dropdown_cipher] == 'hill_cipher' && params[:input_text] && params[:decrypt_button]
      block_size = params[:block_size].to_i
      matrix = StringHelper.prepare_key_hill_cipher(params, block_size)
      decrypted = CipherHelper.dec_hill_cipher(trimed, block_size, matrix)
      flash[:show_element] = true
      flash[:result] = decrypted

    elsif params[:dropdown_cipher] == 'super_enkripsi' && params[:input_text] && params[:encrypt_button]
      encrypted = CipherHelper.enc_extended_vigenere_cipher(params[:input_text], params[:key])
      transposisi = CipherHelper.enc_trans_vertical(encrypted, params[:key].length)
      flash[:show_element] = true
      flash[:result] = Base64.encode64(transposisi)

    elsif params[:dropdown_cipher] == 'super_enkripsi' && params[:input_text] && params[:decrypt_button] && params[:m] && params[:b]
      params[:input_text] = Base64.decode64(params[:input_text])
      last_x_idx = params[:input_text].rindex('X')
      padding_length = params[:input_text][(last_x_idx+1)..-1].to_i
      params[:input_text] = params[:input_text][0..last_x_idx]
      # Rails.logger.debug "how many pad length #{padding_length} last idx: #{last_x_idx} input: #{params[:input_text]}"
      transposisi = CipherHelper.dec_trans_vertical(params[:input_text], params[:key].length, padding_length)
      decrypted = CipherHelper.dec_extended_vigenere_cipher(transposisi, params[:key])
      # Rails.logger.debug "result decrypt vig #{decrypted}"
      flash[:show_element] = true
      flash[:result] = decrypted
    
    else 
      flash[:show_element] = false
    end
    
    # Redirect to another location after processing the form data
    redirect_back(fallback_location: root_path)
  end
end