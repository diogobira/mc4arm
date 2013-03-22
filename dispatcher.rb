require 'parametros'
require 'simulador'

class Dispatcher

	def initialize(file,runtimes)
		@p = Parametros.new(file)
		@s = Simulador.new(@p)
		@t = runtimes
	end

	def run
		threads = Array.new
		(1..@t).each do |i|
			#threads << Thread.new {@s.executar}
			@s.executar
		end
		#threads.each {|thr| thr.join}
	end

end
