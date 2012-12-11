class Array
	def comprehend args = [], result=[], &block
		if empty? then 
			r = yield *args
			result << r if r
		else 
			(self[0]||[]).each { |e| self[1..-1].comprehend( args + [e], result, &block) }
		end
		result
	end
end

