require 'loader.rb'
require 'probability.rb'
require 'participantes_helper.rb'

class PlanoPrevidencia

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
				contribuicao_mensal = c * (1-@previdencia_tx_adm_ativos)				
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
		beneficio_mensal = b * (1-@previdencia_tx_adm_aposentados)					
		beneficio_anual = beneficio_mensal * @previdencia_qtd_pagamentos_ano
		return beneficio_anual
	end

	####################################################################
	#Processos relacionados a previdência
	####################################################################

	#Roda processo de atualização de idades
	def processa_idade(participantes)
		participantes.map! do |p| 	
			p.idade = p.idade + 1
			#p.dependentes.map! {|d| d.idade= d.idade + 1}
            p
		end
		return participantes
	end

	#Roda processo de aposentadoria
	def processa_aposentadoria(participantes)

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
					end
				when "F"
					if participantes[i].idade >= idade_m and participantes[i].tempo_empresa >= t_minimo
						participantes[i].status = "Desligado"  
					end
				end
		end

		return participantes

	end

	#Roda processo de mortalidade
	def processa_morte(participantes)
		participantes.map! do |p|
			if p.vivo
				if morreu(p)
					p.vivo = false
					p.status = "Desligado"
				end
			end
            p
		end
		return participantes
	end

	#Roda processo de invalidez
	def processa_invalidez(participantes)
		participantes.map! do |p|
			if p.vivo and !(p.invalido)
				if entrou_invalidez(p)
					p.invalido = true
					p.status = "Desligado"
				end
			end
            p
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
		prob_morte = @t.probabilidade_morte(p)
		morto = Probability.random_sample(1, :Bernoulli, [prob_morte])
		morto == 1 ? s = false : s = true
	end

	#Sorteia a invalidez de um determinado participante
	def entrou_invalidez(p)
		prob_invalidez = @t.probabilidade_invalidez(p)
		invalido = Probability.random_sample(1, :Bernoulli, [prob_invalidez])
		invalido == 1 ? s = false : s = true
	end

end
