module StringHelper
    def self.trim_string(string)
        regex = /[^a-zA-Z]/
        string.gsub(regex, '').upcase
    end

    def self.prepare_playfair_text(string)
        mod_txt = ""
        string.chars.each_with_index do |char, index|
            mod_txt += char
            if string[index] == string[index + 1]
                mod_txt += 'X'
            end
        end
        mod_txt += 'X' if mod_txt.length.odd?
    end

    def self.prepare_key_hill_cipher(params, n)
        params_values = (0...n**2).map do |index|
            params[index.to_s].to_i  
        end
        matrix = params_values.each_slice(n).to_a
        return matrix
    end
end