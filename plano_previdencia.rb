class PlanoPrevidencia

	def initialize(h)

		#Atributos simples
		h.each_pair {|k,v| instance_variable_set("@#{key}",v)} 			

		#Tabelas e Tábuas
		@t = Tabelas.new(h)		

		#Atributos estruturados
		@tabela_salarial = @t.tabela_salarial
		@tabela_ats = @t.tabela_ats
		@tabela_contribuicao = @t.tabela_contribuicao
		@tabela_joia = @t.tabela_joia
		@tabela_funcoes = @t.tabela_funcoes
		@tabua_mortalidade = @t.tabua_mortalidade
		@tabua_invalidez = @t.tabua_invalidez

	end

	####################################################################
	#Cálculos de contribuições e benefícios
	####################################################################

	def contribuicao_anual(participante)
		p = participante
		case p.status
			when "Ativo"
				contribuicao = 0
			when "Aposentado"
				contribuicao = 0
		end

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
		participantes.each do |p|
			if p.vivo
				if morreu(p)
					p.vivo = false
					p.status = "Desligado"
				end
			end
		end
		return participantes
	end

	#Roda processo de invalidez
	def processa_invalidez(participantes)
		participantes.each do |p|
			if p.vivo and !(p.invalido)
				if entrou_invalidez(p)
					p.invalido = true
					p.status = "Desligado"
				end
			end
		end
		return participantes
	end

	#Roda processo de atualização de dependentes
	def processa_dependente(participantes)
		return participantes
	end

	####################################################################
	#Métodos de apoio aos processos previdenciários
	####################################################################

	#Sorteia a morte de um determinado participante
	def morreu(p)
		p_morto = @t.probabilidade_morte(p)
		p_vivo = Probability.uniform(1, params).first
		p_vivo >= p_morto ? s = false : s = true
	end

	#Sorteia a invalidez de um determinado participante
	def entrou_invalidez(p)
		p_invalido = @t.probabilidade_invalidez(p)
		p_valido = Probability.uniform(1, params).first
		p_valido >= p_invalido ? s = false : s = true
	end

end
