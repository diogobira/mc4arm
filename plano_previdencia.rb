class PlanoPrevidencia

	def initialize(h)

		#Atributos simples
		h.each_pair {|k,v| instance_variable_set("@#{key}",v)} 			

		#Atributos estruturados
		@tabela_salarial = load_tabela_salarial(@patrocinador_tabela_salarial)
		@tabela_ats = load_tabela_ats(@patrocinador_tabela_ats)
		@tabela_funcoes = load_tabela_funcoes(@patrocinador_tabela_funcoes)
		@tabua_mortalidade = load_tabua_mortalidade(@previdencia_tabua_mortalidade)
		@tabua_invalidez = load_tabua_invalidez(@previdencia_tabua_invalidez)

	end

	####################################################################
	#Cálculos de contribuições e benefícios
	####################################################################

	def contribuicao_anual(participante)
		return contribuicao
	end

	def beneficio_anual(participante)
		p = participante
		return beneficio
	end

	####################################################################
	#Processos relacionados a previdência
	####################################################################

	#Roda processo de atualização de idades
	def processa_idade(participantes)
		participantes.map! do |p| 	
			p.idade = p.idade + 1
			p.dependentes.map! do |d|
				d.idade = d.idade + 1
			end
		end
		return participantes
	end

	#Roda processo de aposentadoria
	def processa_aposentadoria(participantes)
		return participantes
	end

	#Roda processo de mortalidade
	def processa_morte(participantes)
		return participantes
	end

	#Roda processo de invalidez
	def processa_invalidez(participantes)
		return participantes
	end

	#Roda processo de atualização de dependentes
	def processa_dependente(participantes)
		return participantes
	end

	####################################################################
	#Métodos de carga de parâmetros estruturados
	####################################################################
	def	load_tabua_mortalidade(arquivo)
		tabua_mortalidade = csv2hashes(arquivo)
	end

	def load_tabua_invalidez(arquivo)
		tabua_invalidez = csv2hashes(arquivo)
	end




end
