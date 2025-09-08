-- ---
-- Projeto: Gerador de Arquivos INI a partir de Tabelas Lua
-- Descrição: Uma ferramenta de linha de comando que lê uma estrutura de tabela Lua
--            de um arquivo de entrada e a converte para o formato de arquivo INI,
--            salvando o resultado em um arquivo de saída. É uma ótima demonstração
--            de como Lua pode ser usada para scripts de configuração e automação.
--
-- Bibliotecas necessárias: Nenhuma. Utiliza apenas as bibliotecas padrão do Lua (io, os, table).
--
-- Como executar: lua main.lua <arquivo_de_entrada.lua> <arquivo_de_saida.ini>
--
-- Exemplo de arquivo de entrada (ex: config.lua):
-- return {
--   database = {
--     host = "localhost",
--     port = 5432,
--     user = "admin",
--     enabled = true
--   },
--   server = {
--     host = "0.0.0.0",
--     port = 8080,
--     enable_ssl = false
--   },
--   logging = {
--     level = "info",
--     path = "/var/log/app.log"
--   }
-- }
--
-- Comando de exemplo com o arquivo acima:
-- lua main.lua config.lua settings.ini
-- ---

--- Converte uma tabela Lua aninhada (um nível de profundidade) para uma string no formato INI.
-- @param config_table A tabela a ser convertida.
-- @return Uma string formatada como um arquivo INI.
local function table_to_ini(config_table)
    local lines = {}
    
    -- Itera sobre cada par chave/valor da tabela principal (as seções do INI)
    for section_name, section_data in pairs(config_table) do
        -- Garante que o valor associado à seção seja de fato uma tabela
        if type(section_data) == "table" then
            table.insert(lines, "[" .. tostring(section_name) .. "]")
            
            -- Itera sobre as chaves e valores dentro da tabela da seção
            for key, value in pairs(section_data) do
                table.insert(lines, tostring(key) .. " = " .. tostring(value))
            end
            
            -- Adiciona uma linha em branco para melhor legibilidade entre as seções
            table.insert(lines, "")
        end
    end
    
    -- Concatena todas as linhas em uma única string, separadas por quebra de linha
    return table.concat(lines, "\n")
end

--- Função principal que orquestra a execução do script.
local function main()
    -- 1. Capturar e validar os argumentos da linha de comando
    local input_file_path = arg[1]
    local output_file_path = arg[2]

    if not input_file_path or not output_file_path then
        print("Erro: Argumentos insuficientes.")
        print("Uso: lua main.lua <arquivo_de_entrada.lua> <arquivo_de_saida.ini>")
        os.exit(1)
    end

    -- 2. Carregar o arquivo de configuração Lua de forma segura
    -- 'pcall' (protected call) executa a função 'dofile' e captura quaisquer erros
    -- sem interromper o script. 'dofile' executa um arquivo Lua e retorna o que ele retorna.
    print("Lendo o arquivo de entrada: " .. input_file_path)
    local ok, config_data = pcall(dofile, input_file_path)

    if not ok then
        print("Erro fatal ao ler ou processar o arquivo de entrada '" .. input_file_path .. "':")
        print(config_data) -- Em caso de erro, 'config_data' contém a mensagem de erro.
        os.exit(1)
    end

    if type(config_data) ~= "table" then
        print("Erro: O arquivo de entrada '" .. input_file_path .. "' deve retornar uma tabela Lua.")
        os.exit(1)
    end

    -- 3. Converter a tabela carregada para o formato INI
    print("Convertendo a tabela para o formato INI...")
    local ini_content = table_to_ini(config_data)

    -- 4. Escrever o conteúdo gerado no arquivo de saída
    print("Escrevendo no arquivo de saída: " .. output_file_path)
    local file, err = io.open(output_file_path, "w")
    if not file then
        print("Erro ao tentar abrir o arquivo de saída '" .. output_file_path .. "': " .. err)
        os.exit(1)
    end

    file:write(ini_content)
    file:close()

    print("\nSucesso! Arquivo '" .. output_file_path .. "' gerado.")
end

-- Ponto de entrada do script
main()
