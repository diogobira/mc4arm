class Simulador

	require 'Persistencia'

	#Inicialização
	def initialize(parametros)
		@p = parametros
		@anoatual = Time.now.year
		@anosimulacao = @anoatual
	end	

	#Executa a simulação
	def executar
	
		#Variáveis de controle da simulação
		ctrl_start_time = Time.now

		#Cópia da lista de participantes para esta instância de execucão da simulação
		participantes = @p.participantes

		#Total inicial de participantes ativos
		total_nm_ativos_inicial = participantes.count{|p| p.nivel == "Medio" and p.status == "Ativo"}
		total_nu_ativos_inicial = participantes.count{|p| p.nivel == "Superior" and p.status == "Ativo"}
		totais_ativos = {:total_nm_ativos_inicial=>total_nm_ativos_inicial, :total_nu_ativos_inicial=>total_nu_ativos_inicial}

		#Loop em todas as combinações de parâmetros	
		@p.combinacoes.comprehend do |c|

			#Array de saída
			cashFlow = Array.new

			#Hash com parametros do loop corrente	
			h = Hash.new
			c.each {|p| h.merge!(p)}
			h.merge!(totais_ativos)

			#Variáveis de acumulação
			receitas,despesas = 0,0

			#Instância objetos de acordo com parametros do loop corrente
			patrocinador = Patrocinador.new(h)
			plano = PlanoPrevidencia.new(h)

			#Loop ao longo de todo horizonte de simulação
			(0...@p.geral_horizonte).each do |i|

				#Atualiza ano corrente da simulação
				@anosimulacao = @anoatual + i

				#Receitas e despesas
				participantes.each do |p|				
					receitas = receitas + plano.contribuicao_anual(p)
					despesas = despesas + plano.beneficio_anual(p)
				end

				#Atualiza o array cashFlow
				fluxo_ano_corrente = {:ano => @anosimulacao, :receitas => receitas,:despesas => despesas}
				cashFlow << fluxo_ano_corrente

				#Processos de atualização da lista de participantes
				participantes = patrocinador.processa_promocao_anual(participantes)
				participantes = patrocinador.processa_ats(participantes)
				participantes = patrocinador.processa_promocao_funcao(participantes)
				participantes = patrocinador.processa_incorporacao_funcao(participantes)
				participantes = patrocinador.processa_salarios(participantes)
				participantes = plano.processa_idade(participantes)
				participantes = plano.processa_morte(participantes)
				participantes = plano.processa_invalidez(participantes)
				participantes = plano.processa_aposentadoria(participantes)
				participantes = patrocinador.processa_contratacoes(participantes)
				#participantes = patrocinador.processa_salarios(participantes)

			end

			#Merge com parametros correntes e salva no banco de dados
		 	h.merge!({:flows => cashFlow})
			#salva no h
			Persistencia.salva("cashflows", h)

		end

	end

end
