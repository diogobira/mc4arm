require 'loader.rb'
require 'probability.rb'

class Patrocinador

	include Loader
	include Probability

	def initialize(h)

		#Atributos simples
		h.each_pair {|k,v| instance_variable_set("@#{key}",v)} 			

		#Atributos estruturados
		@tabela_salarial = load_tabela(@patrocinador_tabela_salarial)
		@tabela_ats = load_tabela(@patrocinador_tabela_ats)
		@tabela_funcoes = load_tabela(@patrocinador_tabela_funcoes)

		#Topos das tabelas
		@topo_nm = @tabela_salarial.select{|s| s[:nivel]="Medio"}.collect{|s| s[:classe]}.max
		@topo_nu = @tabela_salarial.select{|s| s[:nivel]="Superior"}.collect{|s| s[:classe]}.max

	end

	####################################################################
	#Métodos de apoio a simulação
	####################################################################

	#Roda processo de atualização de tempo de empresa para ativos
	def processa_tempo_empresa(participantes)
		participantes.map! {|p| p.status == "Ativo" ? p.tempo_empresa+=1 :	p.tempo_empresa}
		return participantes
	end

	#Roda processo de promoção anual
	def processa_promocao_anual(participantes)

		#Candidatos a promoção
		participantes_nm_indexes = participantes_index({:status=>"Ativo",:nivel=>"Medio",:topado=>false})
		participantes_nu_indexes = participantes_index({:status=>"Ativo",:nivel=>"Superior",:topado=>false})

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
			participantes[i].topado = true if participantes[i].classe == @topo_nm
		end
		participantes_nu_indexes[0,qtd_promovidos_nu].each do |i| 
			participantes[i].classe+=1
			participantes[i].topado = true if participantes[i].classe == @topo_nu
		end

		return participantes

	end

	#Roda processo de atualização de salários
	def processa_salarios(participantes)

		participantes.map! do |p|

			if p.status == "Ativo"

				#Salário base e Ats
				salario_base = @tabela_salarial.detect {|s| s[:quadro] == participante.quadro and s[:classe] == participante.classe}
				ats = @tabela_ats.detect {|a| s[:quadro] == participante.quadro and s[:tempo_empresa] == participante.tempo_empresa}

				#Adicional de função
				if !(p.funcao_ativa.nil?) 
					adicional_funcao = @tabela_funcoes.detect {|f| f[:nome] == participante.funcao_ativa}
				elsif !(p.funcao_incorporada.nil?) 
					adicional_funcao = @tabela_funcoes.detect {|f| f[:nome] == participante.funcao_incorporada}
					adicional_funcao = adicional_funcao * participante.funcao_incorporada_prc
				end

				#Atualiza o salário
				p.salario = (salario_base + salario_base * ats + adicional_funcao) * (1 + @patrocinador_gratificacao)

			end
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
			candidatos.suffle!

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
		#deficit_nm = deficit_nm * 
		#deficit_nu = deficit_nu * 
	
		#Novos participantes
		(1..deficit_nm).each {|i| participantes << Participante.new(:nivel=>"Medio")}
		(1..deficit_nu).each {|i| participantes << Participante.new(:nivel=>"Superior")}

		return participantes

	end

	####################################################################
	#Métodos auxiliares
	####################################################################
	
	#Indices dos participantes que atendem um determinado criterio
	def participantes_index(participantes,h)
		indexes = Array.new
		participantes.each_with_index do |p,index|
			criterios_atendidos = Array.new
			h.each_key do |k|
				criterios_atendidos << p.instance_variable_get("@#{k.to_s}") == h[k]				
			end
			indexes << index if criterios_atendidos.reduce(:&)
		end
		return indexes
	end

	#Indices dos participantes que não atendem a um determinado critério
	def participantes_index_complementar(participantes,h)
		all_indexes = (0..participantes.length-1).to_a
		indexes = participantes_index_complementar(participantes,h)
		return all_indexes - indexes
	end

end
