require 'loader.rb'

class Patrocinador

	include Loader

	def initialize(h)

		#Atributos simples
		h.each_pair {|k,v| instance_variable_set("@#{key}",v)} 			

		#Atributos estruturados
		@tabela_salarial = load_tabela_salarial(@patrocinador_tabela_salarial)
		@tabela_ats = load_tabela_ats(@patrocinador_tabela_ats)
		@tabela_funcoes = load_tabela_funcoes(@patrocinador_tabela_funcoes)
	end

	####################################################################
	#Métodos de apoio a simulação
	####################################################################

	def processa_promocao_anual(participantes)
	end

	def processa_ats(participantes)
	end

	def processa_promocao_funcao(participantes)
	end

	def processa_contratacoes(participantes)
	end

end
