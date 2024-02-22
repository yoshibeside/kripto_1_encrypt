require 'string_helper'
require 'cipher_helper'
require 'valid_helper'

class HomeController < ApplicationController
  include StringHelper
  include CipherHelper
  include ValidHelper

  def index
    # Check if the request method is POST
    Rails.logger.debug "Form parameters: #{params.inspect}"
    if request.post?
      Rails.logger.debug "The request is going through the POST method."
    else
      Rails.logger.debug "The request is not going through the POST method."
    end
  end

  def download_txt
    uuid = params[:uuid]
    data = Rails.cache.read(uuid)
    if data
      send_data data, filename: "data.txt", type: "text/plain"
    else
      # Handle case where data is not found
      render plain: "Data not found", status: :not_found
    end
  end

  def download_binary
    uuid = params[:uuid]
    data = Rails.cache.read(uuid)
    binary_data = data.unpack("B*").first
    if data
      send_data binary_data, filename: "text_binary.bin", type: "application/octet-stream"
    else
      # Handle case where data is not found
      render plain: "Data not found", status: :not_found
    end
  end

  def download_file
    uuid = params[:uuid]
    ext = params[:ext]
    data = Rails.cache.read(uuid)
    # Determine the Content-Type based on the file extension
    content_type = Mime::Type.lookup_by_extension(params[:ext]) || 'application/octet-stream'

    # Set the Content-Disposition to "attachment" to force download
    headers['Content-Disposition'] = "attachment; filename=file.#{ext}"

    send_data data, type: content_type
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
    if (params[:key] == "" && params[:dropdown_cipher] != "affine_cipher" && params[:dropdown_cipher] != "hill_cipher")
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
      flash[:ext] = "txt"
      if params[:file_option] === "text"
        plaintext = file_content
      else 
        plaintext = Base64.decode64(file_content)
      end

    elsif params[:dropdown] == "anyfile" && params[:file_any]

      file_content = File.binread(params[:file_any].tempfile)
      plaintext = file_content
      # Extract the file extension
      file_extension = File.extname(params[:file_any].original_filename)
      flash[:ext] = file_extension.delete('.')

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
      flash[:result] = encrypted

      uuid = SecureRandom.uuid
      Rails.cache.write(uuid, Base64.encode64(encrypted), expires_in: 1.hour)
      flash[:text_data] = uuid
      flash[:binary_data] = uuid
      flash[:result_64] = Base64.encode64(encrypted)

    elsif params[:dropdown_cipher] == 'vig_cipher' && params[:input_text] && params[:decrypt_button]
      decrypted = CipherHelper.dec_vig_cipher_26(trimed, key)
      flash[:show_element] = true
      flash[:result] = decrypted
      flash[:result_64] = Base64.encode64(decrypted)

      uuid = SecureRandom.uuid
      Rails.cache.write(uuid, Base64.encode64(decrypted), expires_in: 1.hour)
      flash[:text_data] = uuid
      flash[:binary_data] = uuid

      
    elsif params[:dropdown_cipher] == 'auto_vig_cipher' && params[:input_text] && params[:encrypt_button]
      encrypted = CipherHelper.enc_autokey_vigenere_cipher(trimed, key)
      flash[:show_element] = true
      
      uuid = SecureRandom.uuid
      Rails.cache.write(uuid, Base64.encode64(encrypted), expires_in: 1.hour)
      flash[:text_data] = uuid
      flash[:binary_data] = uuid
      
      if ValidHelper.check_size(encrypted)
        flash[:result_64] = Base64.encode64(encrypted)
        flash[:result] = encrypted
      else
        flash[:result_64] = "exists"
      end


    elsif params[:dropdown_cipher] == 'auto_vig_cipher' && params[:input_text] && params[:decrypt_button]
      decrypted = CipherHelper.dec_autokey_vigenere_cipher(trimed, key)
      flash[:show_element] = true
      uuid = SecureRandom.uuid
      flash[:text_data] = uuid
      flash[:binary_data] = uuid
      Rails.cache.write(uuid, Base64.encode64(decrypted), expires_in: 1.hour)
      if ValidHelper.check_size(decrypted)
        flash[:result_64] = Base64.encode64(decrypted)
        flash[:result] = decrypted
      else
        flash[:result_64] = "exists (result too big to display)"
      end

    elsif params[:dropdown_cipher] == 'ext_vig_cipher' && params[:input_text] && params[:encrypt_button]
      encrypted = CipherHelper.enc_extended_vigenere_cipher(plaintext, params[:key])
      flash[:show_element] = true
      
      uuid = SecureRandom.uuid
      if (params[:dropdown] == "anyfile")
        Rails.cache.write(uuid, encrypted, expires_in: 1.hour)
        flash[:result] = true
        flash[:other_file_data] = uuid
        flash[:binary_data] = uuid
      else 
        Rails.cache.write(uuid, Base64.encode64(encrypted), expires_in: 1.hour)
        flash[:binary_data] = uuid
        flash[:text_data] = uuid
        if ValidHelper.check_size_64(encrypted)
          flash[:result_64] = Base64.encode64(encrypted)
        else
          flash[:result_64] = "exists (result too big to display)"
        end
      end
      

    elsif params[:dropdown_cipher] == 'ext_vig_cipher' && params[:input_text] && params[:decrypt_button]
      decrypted = CipherHelper.dec_extended_vigenere_cipher(plaintext, params[:key])
      flash[:show_element] = true
      uuid = SecureRandom.uuid
      if (params[:dropdown] == "anyfile")
        Rails.cache.write(uuid, decrypted, expires_in: 1.hour)
        flash[:result] = true
        flash[:other_file_data] = uuid
        flash[:binary_data] = uuid
      else 
        Rails.cache.write(uuid, Base64.encode64(decrypted), expires_in: 1.hour)
        flash[:binary_data] = uuid
        flash[:text_data] = uuid
        if ValidHelper.check_size_64(decrypted)
          flash[:result_64] = Base64.encode64(decrypted)
          flash[:result] = decrypted
        else
          flash[:result_64] = "exists (result too big to display)"
        end
      end

    elsif params[:dropdown_cipher] == 'playfair_cipher' && params[:input_text] && params[:encrypt_button]
      mod_text = StringHelper.prepare_playfair_text(trimed)
      encrypted = CipherHelper.enc_playfair_cipher(mod_text, params[:key])
      flash[:show_element] = true
      uuid = SecureRandom.uuid
      Rails.cache.write(uuid, Base64.encode64(encrypted), expires_in: 1.hour)
      flash[:text_data] = uuid
      flash[:binary_data] = uuid
      if ValidHelper.check_size_64(encrypted)
        flash[:result_64] = Base64.encode64(encrypted)
        flash[:result] = encrypted
      else
        flash[:result_64] = "exists (result too big to display)"
      end

    elsif params[:dropdown_cipher] == 'playfair_cipher' && params[:input_text] && params[:decrypt_button]
      decrypted = CipherHelper.dec_playfair_cipher(trimed, params[:key])
      flash[:show_element] = true
      uuid = SecureRandom.uuid
      Rails.cache.write(uuid, Base64.encode64(decrypted), expires_in: 1.hour)
      flash[:text_data] = uuid
      flash[:binary_data] = uuid
      if ValidHelper.check_size(decrypted)
        flash[:result_64] = Base64.encode64(decrypted)
        flash[:result] = decrypted
      else
        flash[:result_64] = "exists (result too big to display)"
      end


    elsif params[:dropdown_cipher] == 'affine_cipher' && params[:input_text] && params[:encrypt_button] && params[:m] && params[:b]
      encrypted = CipherHelper.enc_affine_cipiher(trimed, params[:m].to_i, params[:b].to_i)
      flash[:show_element] = true
      uuid = SecureRandom.uuid
      Rails.cache.write(uuid, Base64.encode64(encrypted), expires_in: 1.hour)
      flash[:text_data] = uuid
      flash[:binary_data] = uuid
      if ValidHelper.check_size_64(encrypted)
        flash[:result_64] = Base64.encode64(encrypted)
        flash[:result] = encrypted
      else
        flash[:result_64] = "exists (result too big to display)"
      end

    elsif params[:dropdown_cipher] == 'affine_cipher' && params[:input_text] && params[:decrypt_button] && params[:m] && params[:b]
      decrypted = CipherHelper.dec_affine_cipher(trimed, params[:m].to_i,  params[:b].to_i)
      flash[:show_element] = true
      uuid = SecureRandom.uuid
      Rails.cache.write(uuid, Base64.encode64(decrypted), expires_in: 1.hour)
      flash[:text_data] = uuid
      flash[:binary_data] = uuid
      if ValidHelper.check_size(decrypted)
        flash[:result_64] = Base64.encode64(decrypted)
        flash[:result] = decrypted
      else
        flash[:result_64] = "exists (result too big to display)"
      end

    elsif params[:dropdown_cipher] == 'hill_cipher' && params[:input_text] && params[:encrypt_button]
      block_size = params[:block_size].to_i
      matrix = StringHelper.prepare_key_hill_cipher(params, block_size)
      encrypted = CipherHelper.enc_hill_cipher(trimed, block_size, matrix)
      flash[:show_element] = true
      uuid = SecureRandom.uuid
      Rails.cache.write(uuid, Base64.encode64(encrypted), expires_in: 1.hour)
      flash[:text_data] = uuid
      flash[:binary_data] = uuid
      if ValidHelper.check_size_64(encrypted)
        flash[:result_64] = Base64.encode64(encrypted)
        flash[:result] = encrypted
      else
        flash[:result_64] = "exists (result too big to display)"
      end

    elsif params[:dropdown_cipher] == 'hill_cipher' && params[:input_text] && params[:decrypt_button]
      block_size = params[:block_size].to_i
      matrix = StringHelper.prepare_key_hill_cipher(params, block_size)
      decrypted = CipherHelper.dec_hill_cipher(trimed, block_size, matrix)
      flash[:show_element] = true
      uuid = SecureRandom.uuid
      Rails.cache.write(uuid, Base64.encode64(decrypted), expires_in: 1.hour)
      flash[:text_data] = uuid
      flash[:binary_data] = uuid
      if ValidHelper.check_size(decrypted)
        flash[:result_64] = Base64.encode64(decrypted)
        flash[:result] = decrypted
      else
        flash[:result_64] = "exists (result too big to display)"
      end

    elsif params[:dropdown_cipher] == 'super_enkripsi' && params[:input_text] && params[:encrypt_button]
      encrypted = CipherHelper.enc_extended_vigenere_cipher(plaintext, params[:key])
      Rails.logger.debug "encripy #{encrypted}"
      transposisi = CipherHelper.enc_trans_vertical(encrypted, params[:key])
      Rails.logger.debug "result transposisi #{transposisi}"
      flash[:show_element] = true
      
      uuid = SecureRandom.uuid
      if (params[:dropdown] == "anyfile")
        Rails.cache.write(uuid, transposisi, expires_in: 1.hour)
        flash[:result] = true
        flash[:other_file_data] = uuid
        flash[:binary_data] = uuid
      else 
        Rails.cache.write(uuid, Base64.encode64(transposisi), expires_in: 1.hour)
        flash[:binary_data] = uuid
        flash[:text_data] = uuid
        if ValidHelper.check_size_64(transposisi)
          flash[:result_64] = Base64.encode64(transposisi)
        else
          flash[:result_64] = "exists (result too big to display)"
        end
      end

    elsif params[:dropdown_cipher] == 'super_enkripsi' && params[:input_text] && params[:decrypt_button]
      # Rails.logger.debug "how many pad length #{padding_length} last idx: #{last_x_idx} input: #{params[:input_text]}"
      transposisi = CipherHelper.dec_trans_vertical(plaintext, params[:key])
      Rails.logger.debug "posisi #{transposisi}"
      decrypted = CipherHelper.dec_extended_vigenere_cipher(transposisi, params[:key])
      Rails.logger.debug "result decrypt vig #{decrypted}"
      flash[:show_element] = true
      uuid = SecureRandom.uuid
      if (params[:dropdown] == "anyfile")
        Rails.cache.write(uuid, decrypted, expires_in: 1.hour)
        flash[:result] = true
        flash[:other_file_data] = uuid
        flash[:binary_data] = uuid
      else 
        Rails.cache.write(uuid, Base64.encode64(decrypted), expires_in: 1.hour)
        flash[:binary_data] = uuid
        flash[:text_data] = uuid
        if ValidHelper.check_size_64(decrypted)
          flash[:result_64] = Base64.encode64(decrypted)
          flash[:result] = decrypted
        else
          flash[:result_64] = "exists (result too big to display)"
        end
      end
    end
    
    # Redirect to another location after processing the form data
    redirect_back(fallback_location: root_path)
  end
end