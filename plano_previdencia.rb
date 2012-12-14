class PlanoPrevidencia

	def initialize(h)

		#Atributos simples
		h.each_pair {|k,v| instance_variable_set("@#{key}",v)} 			

		#Atributos estruturados
		@tabela_salarial = load_tabela(@patrocinador_tabela_salarial)
		@tabela_ats = load_tabela(@patrocinador_tabela_ats)
		@tabela_contribuicao = load_tabela(@previdencia_tabela_contribuicao)
		@tabela_joia = load_tabela(@previdencia_tabela_joia)
		@tabela_funcoes = load_tabela(@patrocinador_tabela_funcoes)
		@tabua_mortalidade = load_tabua(@previdencia_tabua_mortalidade)
		@tabua_invalidez = load_tabua(@previdencia_tabua_invalidez)

	end

	####################################################################
	#Cálculos de contribuições e benefícios
	####################################################################

=begin
 previdencia_tabela_contribuicao: SimpleList;String;data/tabela_contribuicao.csv
 previdencia_tabela_joia: SimpleList;String;data/tabela_joia.csv
 previdencia_qtd_contribuicoes_ano: SimpleList;Number;13,14,15
 previdencia_qtd_pagamentos_ano: SimpleList;Number;13,13,14
 previdencia_tx_adm_ativos: SimpleList;Number;8,9,10
 previdencia_tx_adm_aposentados: SimpleList;Number;5,6,7
 previdencia_nivel_nu_teto: SimpleList;Number;17
 previdencia_nivel_nm_teto: SimpleList;Number;10
 previdencia_contribuicao_patrocinador: SimpleList;Number;1	
 previdencia_inss_teto_aposentadoria: SimpleList;Number;3400
=end

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
			if p.vivo?
				if matou(p)
					p.vivo = false
					p.status = "Desligado"
				end
			end
		end

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

	####################################################################
	#Métodos de pesquisa nas tabelas e tábuas
	####################################################################
	def fatores_contribuicao(h)
		fatores = @tabela_contribuicao.detect do |c| 
			p[:quadro]==c[:quadro] and \
			p[:nivel]==c[:nivel] and \		
			p[:classe]==c[:classe] and
		end
		return fatores
	end

	def fator_joia(h)
		#fator = 
		return fator
	end

	#Sorteia a morte de um determinado participante de acordo com a tábua de mortalidade
	def matou(p)
		linha = @tabua_mortalidade.detect {|t| p.sexo == t[:sexo] and p.idade == t[:idade]}
		p_morto = 
		p_vivo = Probability.uniform(1, params).first
		p_vivo >= p_morto ? s = false : s = true
	end

end
