require 'log4r'
require 'loader.rb'
require 'probability.rb'
require 'participantes_helper.rb'
require 'dependente.rb'

class PlanoPrevidencia

	include Log4r
	include Loader
	include Probability
	include ParticipantesHelper

	def initialize(h)

		#Atributos simples
		h.each_pair {|k,v| instance_variable_set("@#{k}",v)} 			

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
		@tabela_dependentes = @t.tabela_dependentes

		@log = Logger.new 'PlanoPrevidencia'
		@log.outputters = Outputter.stdout

	end

	####################################################################
	#Cálculos de contribuições e benefícios
	####################################################################

	#Calculo da contribuicao anual liquida do participante
	def contribuicao_anual(participante)
		p = participante
		sc = p.salario
		tinss = @previdencia_inss_teto_aposentadoria
		f = @t.fatores_contribuicao(p)
		c = f[:f1]*sc + f[:f2]*(sc-tinss/2) + f[:f3]*(sc-tinss)
		case p.status
			when "Ativo"
				contribuicao_mensal = c * (1-@previdencia_tx_adm_ativos/100)				
			when "Desligado"
				contribuicao_mensal = 0
		end
		contribuicao_anual = contribuicao_mensal * @previdencia_qtd_contribuicoes_ano
		return contribuicao_anual
	end

	#Calculo do beneficio anual liquido a ser recebido por um participante
	def beneficio_anual(participante)
		p = participante
		b = p.beneficio
		beneficio_mensal = b * (1-@previdencia_tx_adm_aposentados/100)					
		beneficio_anual = beneficio_mensal * @previdencia_qtd_pagamentos_ano

		if p.vivo
			#Benefício recebido pelo próprio participante
			beneficio_anual_ajustado = beneficio_anual
		elsif dependentes_ativos(p)
			#Benefício recebido por um dependente (caso necessário, define o fator de pensao)
			if p.fator_pensao.nil?
				fp = @t.fator_pensao(p)
				p.fator_pensao = fp
			end
			beneficio_anual_ajustado = beneficio_anual * p.fator_pensao
		else
			beneficio_anual_ajustado = 0
		end
		return beneficio_anual_ajustado
	end

	####################################################################
	#Processos relacionados a previdência
	####################################################################

	#Roda processo de atualização de idades
	def processa_idade(participantes)
		participantes.map! do |p| 	
			#Atualiza idade dos participantes
			p.idade = p.idade + 1
			#Atualiza idade dos dependentes
			p.dependentes.map! do |d|
				d.idade = d.idade + 1 
				d
			end
      p
		end
		return participantes
	end

	#Roda processo de aposentadoria
	def processa_aposentadoria(participantes)

		#Contadores auxiliares
		conta_aposentadorias = 0

		#Idades e tempos mínimos para aposentadoria
		idade_h = @previdencia_inss_idade_aposentadoria_homem
		idade_m = @previdencia_inss_idade_aposentadoria_mulher
		t_minimo = @previdencia_tempo_minimo

		#Participantes ativos
		ativos_indexes = participantes_ativos(participantes) 

		#Regras para aposentadoria
		ativos_indexes.each do |i|
			case participantes[i].sexo
				when "M"
					if participantes[i].idade >= idade_h and participantes[i].tempo_empresa >= t_minimo
						participantes[i].status = "Desligado"  
						conta_aposentadorias = conta_aposentadorias + 1
					end
				when "F"
					if participantes[i].idade >= idade_m and participantes[i].tempo_empresa >= t_minimo
						participantes[i].status = "Desligado"  
						conta_aposentadorias = conta_aposentadorias + 1
					end
				end
		end

	#	@log.debug "#{Time.now} Total de aposentadorias processadas:#{conta_aposentadorias}/#{ativos_indexes.length}"

		return participantes

	end

	#Roda processo de mortalidade
	def processa_morte(participantes)

		#Contadores auxiliares
		conta_mortes = 0
		conta_vivos = 0
		
		participantes.map! do |p|

			#Cria dependentes caso ainda não tenham sido criados
			if p.dependentes.empty?
				cria_dependentes(p)
			end

			if p.vivo
				#Morte dos participantes
        conta_vivos = conta_vivos + 1
				if morreu(p)
					p.vivo = false
					p.status = "Desligado"
					conta_mortes = conta_mortes + 1
				end
			else
				#Morte dos dependentes
				p.dependentes.map! do |d|
					if d.tipo == "Conjuge" and d.vivo == true
						d.vivo = false if morreu(d) 
					end
					if d.tipo == "Filho" and d.vivo == true	
						d.vivo = false if d.idade > @previdencia_idade_maxima_pensao_filho
					end
					d
				end
			end
      p
		end
		#	@log.debug "#{Time.now} Total de mortes processadas:#{conta_mortes}/#{conta_vivos}"
		return participantes
	end

	#Roda processo de invalidez
	def processa_invalidez(participantes)
		#Contadores auxiliares
		conta_vivos_validos = 0
		conta_invalidos = 0
		participantes.map! do |p|
			if p.vivo and !(p.invalido)
				conta_vivos_validos = conta_vivos_validos + 1
				if entrou_invalidez(p)
					p.invalido = true
					p.status = "Desligado"
					conta_invalidos = conta_invalidos + 1
				end
			end
      p
		end
	#	@log.debug "#{Time.now} Total de entradas em invalidez processadas:#{conta_invalidos}/#{conta_vivos_validos}"
		return participantes
	end


	####################################################################
	#Métodos de apoio aos processos previdenciários
	####################################################################

	#Sorteia a morte de um determinado participante
	def morreu(p)
		prob_morte = @t.probabilidade_morte(p)
		morto = Probability.random_sample(1, :Bernoulli, [prob_morte])
		morto == 1 ? s = true : s = false
	end

	#Sorteia a invalidez de um determinado participante
	def entrou_invalidez(p)
		prob_invalidez = @t.probabilidade_invalidez(p)
		invalido = Probability.random_sample(1, :Bernoulli, [prob_invalidez])
		invalido == 1 ? s = true : s = false
	end

	####################################################################
	#Métodos de apoio a manipulação de dependentes
	####################################################################

	#Cria dependentes para um participante	
	def cria_dependentes(p)

		#Dados da tabela de dependentes
		h = @t.dados_dependentes(p)
		prob_casado = h[:prob_casado] 
		prob_filho = h[:prob_filho]
		idade_cacula = h[:idade_cacula] 
		idade_conjuge = h[:idade_conjuge] 
		
		#Tenta gerar o conjuge
		p.sexo == "M" ? sexo_conjuge = "F" : sexo_conjuge = "M"    
		casado = Probability.random_sample(1, :Bernoulli, [prob_casado])
		if casado
			conjuge_ativo = true
			d = Dependente.new({:sexo => sexo_conjuge,:idade => idade_conjuge,:tipo => "Conjuge",:pensao => p.beneficio})
			p.dependentes << d
		end

		#Tenta gerar o filho
		filho = Probability.random_sample(1, :Bernoulli, [prob_filho])
		if filho
			f = Dependente.new({:sexo => "",:idade => idade_cacula, :tipo => "Filho", :pensao => p.beneficio})
			p.dependentes << f
		end

	end

	#Verifica se existem dependentes ativos
	def dependentes_ativos(p)
		return !(p.dependentes.select{|d| d.vivo}.empty?)		
	end

end
