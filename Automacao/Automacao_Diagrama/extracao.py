import os
import glob
import subprocess
import time
import zipfile
import subprocess

def esperar_e_identificar_zip(download_dir, timeout=60):
    """
    Espera até que um arquivo .zip apareça no diretório de download e retorna seu caminho.
    Caso nenhum arquivo seja encontrado em 'timeout' segundos, levanta uma exceção.
    """
    end_time = time.time() + timeout
    while time.time() < end_time:
        # Procura por arquivos .zip no diretório de download
        arquivos_zip = glob.glob(os.path.join(download_dir, '*.zip'))
        if arquivos_zip:
            # Seleciona o arquivo mais recente (com base na data de criação)
            arquivo_recente = max(arquivos_zip, key=os.path.getctime)
            # Verifica se o arquivo já está completamente baixado (checa se o tamanho estabilizou)
            tamanho_inicial = os.path.getsize(arquivo_recente)
            time.sleep(2)  # espera um instante
            tamanho_final = os.path.getsize(arquivo_recente)
            if tamanho_inicial == tamanho_final:
                return arquivo_recente
        time.sleep(1)
    raise Exception("Nenhum arquivo ZIP foi encontrado no diretório em tempo hábil.")

def extrair_zip(caminho_zip, pasta_destino=None):
    """
    Extrai o conteúdo do arquivo ZIP para a pasta de destino.
    Se 'pasta_destino' não for informado, usa o diretório onde o ZIP está localizado.
    Retorna uma lista com os caminhos completos dos arquivos extraídos.
    """
    if pasta_destino is None:
        pasta_destino = os.path.dirname(caminho_zip)
    with zipfile.ZipFile(caminho_zip, 'r') as zip_ref:
        zip_ref.extractall(pasta_destino)
        arquivos_extraidos = zip_ref.namelist()
    print(f"Conteúdo extraído para: {pasta_destino}")
    # Retorna os caminhos completos dos arquivos extraídos
    return [os.path.join(pasta_destino, nome) for nome in arquivos_extraidos]

if __name__ == '__main__':
    download_dir = os.getcwd()  # Diretório do projeto
    try:
        # Espera e identifica automaticamente o arquivo ZIP baixado
        caminho_zip = esperar_e_identificar_zip(download_dir, timeout=120)
        print(f"Arquivo ZIP identificado: {caminho_zip}")
        
        # Extrai o conteúdo do ZIP
        arquivos_extraidos = extrair_zip(caminho_zip)
        
        # Procura o arquivo DBF entre os arquivos extraídos
        arquivo_dbf = None
        for arquivo in arquivos_extraidos:
            if arquivo.lower().endswith('.dbf'):
                arquivo_dbf = arquivo
                break

        if arquivo_dbf:
            # Define o novo nome para o arquivo (ex: DENGON.dbf)
            novo_nome = os.path.join(download_dir, "DENGON.dbf")
            # Se já existir um arquivo antigo com esse nome, exclui-o
            if os.path.exists(novo_nome):
                os.remove(novo_nome)
                print(f"Arquivo antigo {novo_nome} removido.")
            os.rename(arquivo_dbf, novo_nome)
            print(f"Arquivo renomeado com sucesso para: {novo_nome}")
        else:
            print("Nenhum arquivo DBF encontrado entre os arquivos extraídos.")
        
        # Exclui o arquivo ZIP baixado
        if os.path.exists(caminho_zip):
            os.remove(caminho_zip)
            print(f"Arquivo ZIP removido: {caminho_zip}")

    except Exception as e:
        print(f"Erro: {e}")

try:
    # Executa o script R
    subprocess.run(["Rscript", "C:\\Users\\Jadson Raphael\\Documents\\Python - Arquivos\\python vscode\\Automacao_Diagrama\\provaveis_diagrama.R"], check=True)
    
    # Se o primeiro rodar com sucesso, executa o script Python
    subprocess.run(["python", "C:\\Users\\Jadson Raphael\\Documents\\Python - Arquivos\\python vscode\\Automacao_Diagrama\\Email.py"], check=True)

    print("Ambos os scripts foram executados com sucesso!")

except subprocess.CalledProcessError as e:
    print(f"Erro ao executar um dos scripts: {e}")


