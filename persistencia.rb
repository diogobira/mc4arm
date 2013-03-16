module Persistencia

		#require 'rubygems'
    #require 'mongo/driver'
		require 'mongo'
    require 'yaml'
   
    ARQUIVO = "env.yml"

    #Lê parâmetros de configuração do MongoDB do arquivo de conf
    conf = (YAML.load_file(ARQUIVO))["mongo"]
    @host = conf["host"]
    @port = conf["port"]
    @nom_db = conf["db"]

    #Inicializa objetos conexão, bd e coleção do MongoDB
    @conn = Mongo::Connection.new(@host, @port)
    @db = @conn[@nom_db]

    #Salva um dado hash como um documento na coleção dada
    def Persistencia.salva(nome_col, h)
        col = @db[nome_col]
        col.save(h)
    end

    def Persistencia.le(nome_col, criterios)
        @db[nome_col].find(criterios) do |doc|
            yield doc
        end
    end

end
