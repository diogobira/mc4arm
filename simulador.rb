require 'log4r'
require 'yaml'
require 'persistencia.rb'
require 'array.rb'
require 'patrocinador.rb'
require 'plano_previdencia.rb'
require 'participantes_helper.rb'
require 'digest/sha1'

class Simulador

	include Log4r
	include ParticipantesHelper

	#Inicializacao
	def initialize(parametros)

		#Informações gerais sobre a simulação e ID da simulação
		@sim_date = Time.now
		@sim_description = "Simulações de Teste"
		@sim_key = Digest::SHA1.hexdigest "#{@sim_date}"
		@sim_info = {:date=> @sim_date, :description=> @sim_description, :sim_key=> @sim_key}

		#Parametros de simulação
		@p = parametros
		@anoatual = Time.now.year
		@anosimulacao = @anoatual
	
		#Configurações de logging
		@log = Logger.new 'log'
		@log.outputters = Outputter.stdout

	end	

	#Executa a simulacao
	def executar
	
		@log.info "#{Time.now} Simulacao iniciada (#{@sim_key})"

		#Variáveis de controle da simulacao
		ctrl_start_time = Time.now

		#Cópia da lista de participantes para esta instância de execucao da simulacao
    participantes = @p.participantes
		participantes_dump = Marshal.dump(participantes)

		#Total inicial de participantes ativos
		total_nm_ativos_inicial = participantes.count{|p| p.nivel == "Medio" and p.status == "Ativo"}
		total_nu_ativos_inicial = participantes.count{|p| p.nivel == "Superior" and p.status == "Ativo"}
		totais_ativos = {:total_nm_ativos_inicial=>total_nm_ativos_inicial, :total_nu_ativos_inicial=>total_nu_ativos_inicial}

		#Total de Combinacoes e de participantes
		counter_combs = @p.combinacoes.map{|x| x.length}.reduce(:*)
		@log.info "#{Time.now} Total de combinacoes: #{counter_combs}"
		@log.info "#{Time.now} Total inicial de participantes: #{@p.participantes.length}"

		#Loop em todas as combinacões de parâmetros	
		cur_comb = 1	
		@p.combinacoes.comprehend do |c|
			
			#Reinicia lista de participantes e dependentes
			participantes = Marshal.load(participantes_dump)

			@log.info "#{Time.now} Simulando combinacao #{cur_comb}/#{counter_combs}"

			#Arrays de saída
			cashFlow = Array.new
			participantesFlow = Array.new

			#Hash com parametros do loop corrente	
			h = Hash.new
			c.each {|p| h.merge!(p)}
			h.merge!(totais_ativos)
      h.merge!(@p.nao_combinaveis)

			#Variáveis de acumulacao
			receitas,despesas = 0,0

			#Instância objetos de acordo com parametros do loop corrente
			@log.info "#{Time.now} Instanciando Patrocinador"
			patrocinador = Patrocinador.new(h)

			@log.info "#{Time.now} Instanciando Plano de Previdencia"
			plano = PlanoPrevidencia.new(h)

			#Loop ao longo de todo horizonte de simulacao
			(0...@p.geral_horizonte).each do |i|

				@log.info "#{Time.now} Simulando ano #{i}/#{@p.geral_horizonte}"

				#Obtem resumo das quantidades de participantes
				r = participantes_resumo(participantes)
				@log.info "#{Time.now} Total atual de participantes: #{participantes.length}"
        @log.info "#{Time.now} Total de participantes ativos:#{r[:ativos]}"
        @log.info "#{Time.now} Total de participantes desligados:#{r[:desligados]}"

				#Atualiza array de fluxo de participantes
				fluxo_participantes_ano_corrente = r.merge!({:ano => @anosimulacao})
				participantesFlow << fluxo_participantes_ano_corrente
		
				#Atualiza ano corrente da simulacao
				@anosimulacao = @anoatual + i

				#Receitas e despesas
				@log.info "#{Time.now} Calculando receitas e despesas para ano #{i}/#{@p.geral_horizonte}"
				participantes.each do |p|				
					receitas = receitas + plano.contribuicao_anual(p)
					despesas = despesas + plano.beneficio_anual(p)
				end

				#Atualiza o array cashFlow
				fluxo_ano_corrente = {:ano => @anosimulacao, :receitas => receitas,:despesas => despesas}
				cashFlow << fluxo_ano_corrente

				@log.info "#{Time.now} Iniciando processos de atualizacao dos participantes para #{i}/#{@p.geral_horizonte}"

				#Processos de atualizacao da lista de participantes
				participantes = patrocinador.processa_promocao_anual(participantes)
				#participantes = patrocinador.processa_ats(participantes)
				participantes = patrocinador.processa_promocao_funcao(participantes)
				participantes = patrocinador.processa_incorporacao_funcao(participantes)
				participantes = patrocinador.processa_salarios(participantes)
				participantes = plano.processa_idade(participantes)
				participantes = plano.processa_morte(participantes)
				participantes = plano.processa_invalidez(participantes)
				participantes = plano.processa_aposentadoria(participantes)
				participantes = patrocinador.processa_contratacoes(participantes)
				#participantes = patrocinador.processa_salarios(participantes)

				@log.info "#{Time.now} Finalizando processos de atualizacao dos participantes #{i}/#{@p.geral_horizonte}"

			end

			#Merge com parametros correntes e salva no banco de dados
		 	h.merge!({:flows => cashFlow})
			h.merge!(@sim_info)
			@log.info "#{Time.now} Salvando resultados de simulacao para combinacao #{cur_comb}/#{counter_combs}"
			Persistencia.salva("cashflows", h)
			cur_comb = cur_comb + 1

		end

		@log.info "#{Time.now} Simulacao finalizada"

	end

end
