require 'parametros'
require 'simulador'

class Dispatcher

	def initialize(file,runtimes)
		@p = Parametros.new(file)
		@s = Simulador.new(@p)
		@t = runtimes
	end

	def run
		(1..@t).each do |i|
			@s.executar
		end
	end

end
