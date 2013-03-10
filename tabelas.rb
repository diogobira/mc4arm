require "loader.rb"

class Tabelas

	include Loader

	attr_accessor :tabela_salarial
	attr_accessor :tabela_ats
	attr_accessor :tabela_contribuicao
	attr_accessor :tabela_joia
	attr_accessor :tabela_funcoes
	attr_accessor :tabua_mortalidade
  attr_accessor :tabua_mortalidade_por_invalidez
	attr_accessor :tabua_invalidez
	attr_accessor :tabela_dependentes
	attr_accessor :tabela_fator_pensao


	def initialize(h)
		@tabela_salarial = load_tabela(h[:patrocinador_tabela_salarial])
		@tabela_ats = load_tabela_ats(h[:patrocinador_tabela_ats])
		@tabela_contribuicao = load_tabela_contribuicao(h[:previdencia_tabela_contribuicao])
		@tabela_joia = load_tabela(h[:previdencia_tabela_joia])
		@tabela_fator_pensao = load_tabela_fator_pensao(h[:previdencia_tabela_fator_pensao])
		@tabela_funcoes = load_tabela(h[:patrocinador_tabela_funcoes])
		@tabua_mortalidade = load_tabua(h[:previdencia_tabua_mortalidade])
    @tabua_mortalidade_por_invalidez = load_tabua(h[:previdencia_tabua_mortalidade_por_invalidez])
		@tabua_invalidez = load_tabua(h[:previdencia_tabua_invalidez])
		@tabela_dependentes = load_tabela(h[:previdencia_tabela_dependentes])
		@cap_nu = h[:previdencia_cap_nu]
		@cap_nm = h[:previdencia_cap_nm]
	end

	###########################################################################
	#Métodos de acesso as tabelas salariais
	###########################################################################

	#Retorna o topo da carreira na qual um determinado participante está enquadrado
	def topo_carreira(p)
		t = @tabela_salarial.select {|s| s[:quadro] == p.quadro and s[:nivel] == p.nivel}.last
		return t[:classe]
	end

	#Retorna a classe inicial dados quadro e nivel
	def classe_inicial(quadro,nivel)
		t = @tabela_salarial.select {|s| s[:quadro] == quadro and s[:nivel] == nivel}.first
		return t[:classe]
	end

	#Retorna o salário inicial dados quadro e nivel
	def salario_inicial(quadro,nivel)
		t = @tabela_salarial.select {|s| s[:quadro] == quadro and s[:nivel] == nivel}.first
		return t[:salario_base]
	end

	#Retorna o salário dados quadro, nivel e classe
	def salario(quadro,nivel,classe)
		t = @tabela_salarial.select {|s| s[:quadro]==quadro and s[:nivel]==nivel and s[:classe]=classe}.first
		return t[:salario_base]
	end

	#Retorna o salário base do participante
	def salario_base(p)
			s = @tabela_salarial.detect {|s| s[:quadro] == p.quadro and s[:nivel] == p.nivel and s[:classe] == p.classe}
			return s[:salario_base]			
	end

	#Retorna o salário base de benefício do participante
	def salario_base_beneficio(p)
			classe_topo = topo_carreira(p) + (p.nivel=="Superior" ? @cap_nu : @cap_nm)
			s = @tabela_salarial.detect do |s| 
				s[:quadro] == p.quadro and \
				s[:nivel] == p.nivel and \
				s[:classe] == [p.classe,classe_topo].min
			end
			return s[:salario_base]			
	end

	#Retorna o adicional por tempo de serviço do participante
	def ats(p)
		#a = @tabela_ats.detect {|s| s[:quadro] == p.quadro and s[:tempo_empresa] == p.tempo_empresa}
		a = @tabela_ats.detect(p.quadro,p.tempo_empresa)
		return a[:ats]
	end

	#Retorna o adicional de função do participante
	def adicional_funcao(p)
		if !(p.funcao_ativa.nil?) 
			f = @tabela_funcoes.detect {|f| f[:nome] == p.funcao_ativa}
            adicional = f[:adicional]
		elsif !(p.funcao_incorporada.nil?) 
			f = @tabela_funcoes.detect {|f| f[:nome] == p.funcao_incorporada}
            adicional = f[:adicional]
			adicional = adicional * p.funcao_incorporada_prc
		else
			adicional = 0
		end
		return adicional
	end

	###########################################################################
	#Métodos de acesso às tabelas de contribuição
	###########################################################################

	def fatores_contribuicao(p)
		#fatores = @tabela_contribuicao.detect do |c| 
		#	p.status==c[:status] and  
		#	p.quadro==c[:quadro] and 
		#	p.nivel==c[:nivel] and 		
		#	p.classe==c[:classe]
		#end
		fatores = @tabela_contribuicao.detect(p.status,p.quadro,p.nivel,p.classe)
		return fatores
	end

	def fator_joia(p)
		return 0.05
	end

	###########################################################################
	#Métodos de acesso às tábuas de invalidez e mortalidade
	###########################################################################

	#Retorna a probabilidade de morte de um determinado participante
	def probabilidade_morte(p)
		if !(p.invalido)
			#l = @tabua_mortalidade.detect {|t| p.sexo == t[:sexo] and p.idade == t[:idade]}
			l = @tabua_mortalidade.detect(p.sexo, p.idade)
		else 
			#l = @tabua_mortalidade_por_invalidez.detect {|t| p.sexo == t[:sexo] and p.idade == t[:idade]}
			l = @tabua_mortalidade_por_invalidez.detect(p.sexo, p.idade)
		end
		return l[:prob]/1000
	end

	#Retorna a probabilidade de entrada em invalidez de um determinado participante
	def probabilidade_invalidez(p)
		#l = @tabua_invalidez.detect {|t| p.sexo == t[:sexo] and p.idade == t[:idade]}
		l = @tabua_invalidez.detect(p.sexo,p.idade)
		return l[:prob]/1000
	end

	###########################################################################
	#Métodos de acesso à tabela de dependentes
	###########################################################################
	def dados_dependentes(p)
		h = {
		:prob_casado => 1,
		:prob_filho => 1,
		:idade_cacula => 15,
		:idade_conjuge => 50
		}
		return h
	end

	###########################################################################
	#Métodos de acesso à tabela de fatores de pensão
	###########################################################################
	def fator_pensao(p)
		f = @tabela_fator_pensao.detect(p.sexo,p.tempo_empresa)		
		return f[:fator]	
	end

end
