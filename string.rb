class String

	def to_bool
		return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
		#return false if self == false || self.blank? || self =~ (/(false|f|no|n|0)$/i)
		return false if self == false || self =~ (/(false|f|no|n|0)$/i)
		raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
	end

    def is_numeric?
        self =~ (/^[\d]+(\.[\d]+){0,1}$/)
    end

    def to_numeric
        return self.to_f if self =~ (/^[\d]+(\.[\d]+){0,1}$/)
        return self.to_i if self =~ (/^[\d]+$/)
    end

end
