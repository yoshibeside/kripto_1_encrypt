require 'matrix'

module CipherHelper
    ALPHABET = ('A'..'Z').to_a

    def self.enc_vig_cipher_26(str, key)
        t_enkr = ''
        str.chars.each_with_index do |char, index|
            geser = key[index % key.length].ord - 'A'.ord
            c_enkr = ((char.ord - 'A'.ord + geser) % 26 + 'A'.ord).chr
            t_enkr += c_enkr
        end
        t_enkr
    end

    def self.dec_vig_cipher_26(str, key)
        t_dekr = ''
        str.chars.each_with_index do |char, index|
            geser = key[index % key.length].ord - 'A'.ord
            c_dekr = ((char.ord - 'A'.ord - geser + 26) % 26 + 'A'.ord).chr
            t_dekr += c_dekr
        end
        t_dekr
    end


    def self.enc_autokey_vigenere_cipher(str, key)
        key.upcase!
        key_stream = key + str
        t_enkr = ""
    
        str.each_char.with_index do |char, index|
          geser = key_stream[index].ord - 'A'.ord
          c_enkr = ((char.ord - 'A'.ord + geser) % 26 + 'A'.ord).chr
          t_enkr += c_enkr
        end
        t_enkr
    end

    def self.dec_autokey_vigenere_cipher(str, key)
        key.upcase!
        key_stream = key
        t_dekr = ""
    
        str.each_char.with_index do |char, index|
            geser = key_stream[index].ord - 'A'.ord
            c_dekr = ((char.ord - 'A'.ord - geser + 26) % 26 + 'A'.ord).chr
            t_dekr += c_dekr
            key_stream += c_dekr
        end
        t_dekr
    end

    def self.enc_extended_vigenere_cipher(str, key)
        t_enkr = ""
        key_length = key.length
    
        str.each_char.with_index do |char, index|
            str_char_code = char.ord
            c_key = key[index % key_length].ord
            c_enkr = (str_char_code + c_key) % 256
            t_enkr += c_enkr.chr
        end
        t_enkr
    end

    def self.dec_extended_vigenere_cipher(str, key)
        t_dekr = ""
        key_length = key.length
    
        str.each_char.with_index do |char, index|
            str_char_code = char.ord
            key_char_code = key[index % key_length].ord
            c_dekr = (str_char_code - key_char_code + 256) % 256
            t_dekr += c_dekr.chr
        end
        t_dekr
    end

    def self.prepare_key(key)
        alphabet = ('A'..'Z').to_a - ['J']
        key = key.upcase.gsub(/[^A-Z]/, '')
        key = key.gsub('J', '')
        key_uq_chars = key.chars.uniq.join
        (alphabet - key_uq_chars.chars).unshift(key_uq_chars).join
    end

    def self.generate_playfair_matrix(key)
        matrix = []
        key.each_char do |char|
            if matrix.empty? || matrix.last.length == 5
                matrix << [char]
            else
                matrix.last << char
            end
        end
        matrix
    end

    def self.find_position(matrix, char)
        matrix.each_with_index do |row, x|
            if (y = row.index(char))
                return x, y
            end
        end
        raise "Character not found in the matrix: #{char}"
    end

    def self.enc_playfair_cipher(str, key)
        key = prepare_key(key)
        matrix = generate_playfair_matrix(key)
        t_enkr = ""
        str.scan(/(.)(.?)/) do |pair|
            x1, y1 = find_position(matrix, pair[0])
            x2, y2 = find_position(matrix, pair[1])
            if x1 == x2
                t_enkr << matrix[x1][(y1 + 1) % 5] << matrix[x2][(y2 + 1) % 5]
            elsif y1 == y2
                t_enkr << matrix[(x1 + 1) % 5][y1] << matrix[(x2 + 1) % 5][y2]
            else
                t_enkr << matrix[x1][y2] << matrix[x2][y1]
            end
        end
        t_enkr
    end

    def self.dec_playfair_cipher(str, key)
        key = prepare_key(key)
        matrix = generate_playfair_matrix(key)
    
        t_dekr = ""
        str.scan(/(.)(.?)/) do |pair|
            x1, y1 = find_position(matrix, pair[0])
            x2, y2 = find_position(matrix, pair[1])
            if x1 == x2
                t_dekr << matrix[x1][(y1 - 1) % 5] << matrix[x2][(y2 - 1) % 5]
            elsif y1 == y2
                t_dekr << matrix[(x1 - 1) % 5][y1] << matrix[(x2 - 1) % 5][y2]
            else
                t_dekr << matrix[x1][y2] << matrix[x2][y1]
            end
        end
        t_dekr
    end


    def self.enc_affine_cipiher(str, m, b)
        t_enc = ""
        str.upcase.each_char do |char|
            if ALPHABET.include?(char)
                index = ALPHABET.index(char)
                index_enc = (m * index + b) % 26
                t_enc += ALPHABET[index_enc]
            else
                t_enc += char
            end
        end
        t_enc
    end

    def self.dec_affine_cipher(str, m, b)
        t_dekr = ""
        a_inverse = mod_inverse(m, 26)
        return "Cannot decrypt. 'a' has no modular inverse." unless a_inverse

        str.upcase.each_char do |char|
            if ALPHABET.include?(char)
                index = ALPHABET.index(char)
                decrypted_index = (a_inverse * (index - b)) % 26
                t_dekr << ALPHABET[decrypted_index]
            else
                t_dekr << char
            end
        end
        t_dekr
    end

    def self.mod_inverse(num, modulus)
        (1..modulus).each do |i|
            return i if (num * i) % modulus == 1
        end
        nil # No modular inverse exists
    end

    def self.enc_hill_cipher(plaintext, bl, key)
        n = bl
        key = Matrix[*key]
        padded_plaintext = pad_plaintext(plaintext, n)
        ciphertext = ''
        padded_plaintext.each_slice(n) do |block|
            plaintext_vector = to_numeric_vector(block)
            ciphertext_vector = (key * Matrix.column_vector(plaintext_vector)).map { |x| (x % 26).to_i  }
            ciphertext_vector.map! { |x| x < 0 ? x + 26 : x }
            ciphertext += to_text(ciphertext_vector)
        end
        return ciphertext
    end

        # Decrypts the ciphertext using Hill Cipher
    def self.dec_hill_cipher(ciphertext, block_size, key)
        n = block_size
        padded_ciphertext = pad_plaintext(ciphertext, n)
        key = Matrix[*key]
        plaintext = ''
        inverse_vector = get_inverse(key)
        padded_ciphertext.each_slice(n) do |block|
            ciphertext_vector = to_numeric_vector(block)
            plaintext_vector = (inverse_vector * Matrix.column_vector(ciphertext_vector)).map { |x| x % 26 }
            plaintext += to_text(plaintext_vector)
        end
        plaintext
    end

    # Pads the plaintext with filler characters if necessary to make complete blocks
    def self.pad_plaintext(plaintext, block_size)
        padded_length = (plaintext.length.to_f / block_size).ceil * block_size
        padded_plaintext = plaintext.chars.each_slice(block_size).map do |block|
          block.fill('X', block.length...block_size)
        end
        padded_plaintext.flatten
      end

    def self.get_inverse(matrix)
        dtm = matrix.determinant
        dtm = positive_modulo(dtm)
        dtm_inv = inv_mod(dtm, 26)

        cofac_mat = cofactor_matrix (matrix)
        adj_mat = cofac_mat.transpose

        matrix_array = adj_mat.to_a

        matrix_array.each_with_index do |row, i|
            row.each_with_index do |elm, j|
                adj_mat[i,j] = positive_modulo(elm)
            end
        end
        temp = ((dtm_inv*adj_mat).map { |x| x % 26 })
        return temp
    end  

    def self.minor_matrix(matrix, i, j)
        # Exclude the row at index i and the column at index j
        minor = matrix.to_a.map.with_index { |row, row_index|
          row_index != i ? row.select.with_index { |_, col_index| col_index != j } : nil
        }.compact
        Matrix[*minor]
    end  

    def self.cofactor_matrix(matrix)
        rows, cols = matrix.row_count, matrix.column_count
        cofactors = Array.new(rows) { Array.new(cols) }
      
        (0...rows).each do |i|
          (0...cols).each do |j|
            cofactors[i][j] = (-1)**(i + j) * minor_matrix(matrix, i, j).determinant
          end
        end
      
        Matrix[*cofactors]
      end

    def self.positive_modulo(num)
        while num < 0
            num += 26
        end
        num % 26
    end

    def self.inv_mod(num, modulus)
        gcd, x, y = extended_gcd(num, modulus)
        return nil if gcd != 1
        x = x % modulus
        x += modulus if x < 0
        x
      end
      
      def self.extended_gcd(a, b)
        return [a, 1, 0] if b == 0
        gcd, x1, y1 = extended_gcd(b, a % b)
        x = y1
        y = x1 - (a / b) * y1
        [gcd, x, y]
      end

    # Converts a block of plaintext or ciphertext characters to a numeric vector
    def self.to_numeric_vector(text)
        text.map { |c| c.ord - 'A'.ord }
    end

    # Converts a numeric vector to a block of plaintext or ciphertext characters
    def self.to_text(matrix)
        letters = matrix.map { |num| (num.to_i + 'A'.ord).chr }
        result = letters.to_a.join
        return result
    end
    
    def self.order_key(key)
        sort_char = key.chars.sort_by(&:ord)
        char_idx = key.chars.each_with_index.map { |char, idx| [char,idx]}
        sort_idx = sort_char.map do |char|
            result = nil
            char_idx.each_with_index do |(key, value), idx|
                if key == char
                    result = value
                    char_idx.delete_at(idx)
                    break
                end
            end
            result
        end
        return sort_idx
    end

    def self.dec_order(arr_text)
        asc_pos = arr_text.each_with_index.sort.map(&:last)
        return asc_pos
    end

    def self.enc_trans_vertical(text, key)
        columns = key.length
        rows = (text.length.to_f / columns).ceil

        grid_area = columns*rows
        pad_length = grid_area - text.length

        # adding padding
        text = text.ljust(grid_area, 'X')

        # Create the grid and fill it column by column
        grid = Array.new(rows) { Array.new(columns) }

        count = 0
        (0...(rows)).each do |n|
            (0...(columns)).each do |m|
            grid[n][m] = text[count]
            count += 1
            end
        end
        final_text = ""
        orders = order_key(key)
        orders.each do |idx|
            (0...rows).each do |rows|
                final_text += grid[rows][idx]
            end
        end

        # Read the text out column by column
        final_text += 'X' + pad_length.to_s
    end


    def self.dec_trans_vertical(ciphertext, key)
        # get the last X index
        last_index = ciphertext.rindex('X')
        length_pad = ciphertext[(last_index+1)..-1].to_i
        ciphertext = ciphertext[0..last_index-1]
        
        rows =  key.length
        # Calculate rows based on the ciphertext length and column count
        columns = (ciphertext.length.to_f / rows).ceil
        # Create the grid to hold the columnar data
        grid = Array.new(rows) { Array.new(columns) }

        # Fill the grid column by column
        count = 0
        (0...(rows)).each do |n|
            (0...(columns)).each do |m|
            grid[n][m] = ciphertext[count]
            count += 1
            end
        end
        # Read the text out row by row
        orders = order_key(key)
        orders = dec_order(orders)
        final_text = ""
        (0...columns).each do |col|
            orders.each do |idx|
                final_text += grid[idx][col]
            end
        end

        final_text = final_text[0...-length_pad]
        return final_text
    end

end