require 'loader.rb'
require 'probability.rb'
require 'participantes_helper.rb'
require 'tabelas.rb'

class Patrocinador

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
	#Métodos de apoio a simulação
	####################################################################

	#Roda processo de atualização de tempo de empresa para ativos
	def processa_tempo_empresa(participantes)
		participantes.map! {|p| p.status == "Ativo" ? p.tempo_empresa+=1 : p.tempo_empresa=p.tempo_empresa}
		return participantes
	end

	#Roda processo de promoção anual
	def processa_promocao_anual(participantes)

		#Candidatos a promoção
		participantes_nm_indexes = participantes_index(participantes, {:status=>"Ativo",:nivel=>"Medio",:topado=>false})
		participantes_nu_indexes = participantes_index(participantes, {:status=>"Ativo",:nivel=>"Superior",:topado=>false})

		#Totais de ativos por nível
		total_nm = participantes_nm_indexes.length
		total_nu = participantes_nu_indexes.length

		#Embaralha indices para simular promoção aleatório dentre o grupo
		participantes_nm_indexes.shuffle!
		participantes_nu_indexes.shuffle!
	
		#Quantitativos de participantes ativos a serem promovidos
		qtd_promovidos_nm = (total_nm * @patrocinador_prc_promovidos_ano).ceil
		qtd_promovidos_nu = (total_nu * @patrocinador_prc_promovidos_ano).ceil

		#Altera as classes e, caso necessário, o status de topado
		participantes_nm_indexes[0,qtd_promovidos_nm].each do |i| 
			participantes[i].classe+=1
			participantes[i].topado = true if @t.topo_carreira(participantes[i]) == participantes[i].classe
		end

		participantes_nu_indexes[0,qtd_promovidos_nu].each do |i| 
			participantes[i].classe+=1
			participantes[i].topado = true if @t.topo_carreira(participantes[i]) == participantes[i].classe
		end

		return participantes

	end

	#Roda processo de atualização de salários e beneficio correspondente
	def processa_salarios(participantes)
		participantes.map! do |p|
			if p.status == "Ativo"
				salario_base = @t.salario_base(p)
				salario_beneficio = @t.salario_base_beneficio(p)
				ats = @t.ats(p)
				adicional_funcao = @t.adicional_funcao(p)
				p.salario = (salario_base + salario_base * ats + adicional_funcao) * (1 + @patrocinador_gratificacao)
				p.beneficio = (salario_beneficio + salario_beneficio * ats + adicional_funcao) * (1 + @patrocinador_gratificacao)
			end
            p
		end
		return participantes
	end

	#Roda processo de atualização dos ocupantes de funções comissionadas
	def processa_promocao_funcao(participantes)

		#Posição dos profissionais ativos por nível no vetor de participantes	
		participantes_nm_indexes = participantes_index(participantes,{:status=>"Ativo",:nivel=>"Medio"})
		participantes_nu_indexes = participantes_index(participantes,{:status=>"Ativo",:nivel=>"Superior"})

		#Totais de ativos por nível
		total_nm = participantes_nm_indexes.length
		total_nu = participantes_nu_indexes.length

		#Loop em cada função
		@tabela_funcoes.each do |f|

			#Quantitativos
			case f[:nivel]
				when "Medio"
					vagas = f[:prc] * total_nm
				when "Superior"
					vagas = f[:prc] * total_nu
			end
			ocupantes = participantes_index(participantes,{:status=>"Ativo",:funcao_ativa=>f[:nome]})
			vagas_ocupadas = ocupantes.length			
			vagas_disponiveis = vagas	- vagas_ocupadas	

			#Identifica e embaralha os candidatos para simular aleatoriedade na promoção
			candidatos = participantes_index_complementar(participantes,{:status=>"Ativo",:funcao_ativa=>f[:nome]})			
			candidatos.shuffle!

			#Promove os candidatos
			candidatos[0,vagas_disponiveis].each {|i| participantes[i].funcao_ativa=f[:nome]}

		end
		
		return participantes 		

	end

	#Roda processo de incorporação de função comissionada
	def processa_incorporacao_funcao(participantes)
		return participantes
	end

	#Roda processo de contratações
	def processa_contratacoes(participantes)

		#Ativos por nível
		total_ativos_nm = participantes_index(participantes,{:status=>"Ativo",:nivel=>"Medio"}).length
		total_ativos_nu = participantes_index(participantes,{:status=>"Ativo",:nivel=>"Superior"}).length

		#Déficit por nível com relação aos totais iniciais
		deficit_nm = @total_nm_ativos_inicial - total_ativos_nm
		deficit_nu = @total_nu_ativos_inicial - total_ativos_nu

		#Déficit que serão cobertos
		#deficit_nm = deficit_nm * Probability.
		#deficit_nu = deficit_nu * Probability.

		#Novos participantes
		(1..deficit_nm).each do |i| 
			participantes << Participante.new(
			 {
				:nivel=>"Medio", 	
				:classe=>@t.classe_inicial(@patrocinador_quadro_entrantes,"Medio"),
				:salario=>@t.salario_inicial(@patrocinador_quadro_entrantes,"Medio"),
				:quadro=>@patrocinador_quadro_entrantes,
				:sexo=>(Probability.random_sample(
									1, 
									@patrocinador_prc_homens_entrantes[:distr], 
									@patrocinador_prc_homens_entrantes[:params]
								) == 1) ? "M" : "F",
			    :idade=>Probability.random_sample(
									1, 
									@patrocinador_idade_entrantes[:distr], 
									@patrocinador_idade_entrantes[:params]
                                ).to_i
				}, 
				false
			)
		end

		(1..deficit_nu).each do |i| 
			participantes << Participante.new(
			 {
				:nivel=>"Superior", 
				:classe=>@t.classe_inicial(@patrocinador_quadro_entrantes,"Superior"),
				:salario=>@t.salario_inicial(@patrocinador_quadro_entrantes,"Superior"),
				:quadro=>@patrocinador_quadro_entrantes,
				:sexo=>(Probability.random_sample(
									1, 
									@patrocinador_prc_homens_entrantes[:distr], 
									@patrocinador_prc_homens_entrantes[:params]
								) == 1) ? "M" : "F",
			    :idade=>Probability.random_sample(
									1, 
									@patrocinador_idade_entrantes[:distr], 
									@patrocinador_idade_entrantes[:params]
								).to_i
			 }, 
			 false
			)
		end

		return participantes

	end


end
