module ValidHelper

    def self.check_size(var)
        if (Base64.encode64(var).to_json.bytesize + var.to_json.bytesize) > 2000
            return false
        else
            return true
        end
    end

    def self.check_size_64(var)
        if (Base64.encode64(var).to_json.bytesize) > 2000
            return false
        else
            return true
        end
    end

end