class Browser

	def initialize
	end

	def listar_simulacoes
		puts "Simulações disponíveis para análise:"
		(1..9).each do |i|
			puts "ID000#{i}	Simulação de Teste ID000#{i}"
		end
	end

end
