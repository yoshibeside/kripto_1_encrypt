module StringHelper
    def self.trim_string(string)
        regex = /[^a-zA-Z]/
        string.gsub(regex, '')
    end
end