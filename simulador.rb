class Simulador

	def initialize(parametros)
		@p = parametros
		@anoatual = 
		@anosimulacao = 
	end	

	def executar

		#Cópia da lista de participantes para esta instância de execucão da simulação
		participantes = @p.participantes

		#Array de saída
		cashFlow = Array.new

		#Loop em todas as combinações de parâmetros	
		@p.combinacoes.comprehend do |c|

			#Hash com parametros do loop corrente	
			h = Hash.new
			c.each {|p| h.merge!(p)}

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
				
				#Merge do fluxo corrente com parâmetros
				fluxo_ano_corrente = {:ano => @anosimulacao, :receitas => receitas,:despesas => despesas}

				#Atualiza o array cashFlow 
				cashFlow << fluxo_ano_corrente.merge(h)

				#Processos de atualização da lista de participantes
				participantes = patrocinador.processa_promocao_anual(participantes)
				participantes = patrocinador.processa_ats(participantes)
				participantes = patrocinador.processa_promocao_funcao(participantes)
				participantes = plano.processa_idade(participantes)
				participantes = plano.processa_morte(participantes)
				participantes = plano.processa_invalidez(participantes)
				participantes = plano.processa_aposentadoria(participantes)
				participantes = plano.patrocinador.processa_contratacoes(participantes)

			end

		end

		return cashFlow

	end

end
