class Patrocinador

	def initialize(h)

		#Atributos simples
		h.each_pair {|k,v| instance_variable_set("@#{key}",v)} 			

		#Atributos estruturados
		@tabela_salarios = load_tabela_salarios(@patrocinador_tabela_salarial)
		@tabela_ats = load_tabela_ats(@patrocinador_tabela_ats)
		@tabela_adicionais_funcao = load_tabela_adicionais_funcao(@patrocinador_tabela_adicionais_funcao)
	end

	####################################################################
	#Métodos de apoio a simulação
	####################################################################

	def self.processa_promocao_anual(participantes)
	end

	def self.processa_ats(participantes)
	end

	def self.processa_promocao_funcao(participantes)
	end

	def self.processa_contratacoes(participantes)
	end

	####################################################################
	#Métodos de carga de parâmetros estruturados
	####################################################################
	def load_tabela_salarios(arquivo)
		tabela_salarios = csv2hashes(arquivo)
	end

	def load_tabela_ats(arquivo)
		tabela_ats = csv2hashes(arquivo)
	end

	def load_tabela_adicionais_funcao(arquivo)
		tabela_adicionais_funcao = csv2hashes(arquivo)
	end	

end
