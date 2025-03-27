import os
import datetime
import time
import subprocess
import glob
import zipfile
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

class ExportarBase:
    def __init__(self):
        self.SITE_LINK = "https://sinan.saude.gov.br/sinan/login/login.jsf"
        self.USERNAME = "********"
        self.PASSWORD = "********"
        self.ANO = "2025"

        # Obtém a data atual e calcula a semana epidemiológica
        data_atual = datetime.date.today()
        self.SEMANA_EPI = str(data_atual.isocalendar()[1])

        # Define o diretório de download como a pasta atual do projeto
        download_dir = os.getcwd()

        # Configura as opções do Chrome
        chrome_options = webdriver.ChromeOptions()
        prefs = {
            "download.default_directory": download_dir,
            "download.prompt_for_download": False,
            "download.directory_upgrade": True,
            "safebrowsing.enabled": True
        }
        chrome_options.add_experimental_option("prefs", prefs)

        # Usa o WebDriver Manager para baixar o ChromeDriver correto
        service = Service(ChromeDriverManager().install())

        # Inicializa o WebDriver
        self.driver = webdriver.Chrome(service=service, options=chrome_options)
        self.driver.maximize_window()

    def abrir_site(self):
        self.driver.get(self.SITE_LINK)
        WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.ID, "form:username")))

    def fazer_login(self):
        campo_usuario = self.driver.find_element(By.ID, "form:username")
        campo_usuario.send_keys(self.USERNAME)

        campo_senha = self.driver.find_element(By.ID, "form:password")
        campo_senha.send_keys(self.PASSWORD)
        campo_senha.send_keys(Keys.ENTER)

    def solicitar_export(self):
        menu_toolbar = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.ID, "barraMenu:j_id52_span"))
        )
        menu_toolbar.click()

        opcao = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//*[@id='barraMenu:j_id53:anchor']"))
        )
        opcao.click()

        campo_select = WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.ID, "form:consulta_tipoPeriodo"))
        )
        selecao = Select(campo_select)
        selecao.select_by_value("1")

        campo_ano = WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.XPATH, "//*[@id='form:ano']"))
        )
        campo_ano.send_keys(self.ANO)

        campo_semana_inicial = self.driver.find_element(By.ID, "form:semanaInicial")
        campo_semana_inicial.clear()
        campo_semana_inicial.send_keys("1")

        campo_semana_final = self.driver.find_element(By.ID, "form:semanaFinal")
        campo_semana_final.clear()
        campo_semana_final.send_keys(self.SEMANA_EPI)

        campo_select_uf = WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.ID, "form:tipoUf"))
        )
        selecao_uf = Select(campo_select_uf)
        selecao_uf.select_by_value("3")
        
        solicitar = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//*[@id='form:j_id128']"))
        )
        solicitar.click()

        WebDriverWait(self.driver, 20).until(
            EC.invisibility_of_element_located((By.ID, "ajaxStatusMPDiv"))
        )

        menu_toolbar = WebDriverWait(self.driver, 10).until(
            EC.visibility_of_element_located((By.ID, "barraMenu:j_id52_span"))
        )
        menu_toolbar.click()

        opcao = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//*[@id='barraMenu:j_id56']"))
        )
        opcao.click()
        
    def baixar_export(self):       
        while True:
            try:
                campo = WebDriverWait(self.driver, 5).until(
                    EC.presence_of_element_located((By.XPATH, "/html/body/div[3]/form/span/table/tbody/tr[2]/td[3]"))
                )
                valor_campo = campo.text
                print(f"Valor atual do campo: {valor_campo}")

                # Condição para atualizar a página se o valor for diferente de 'Processamento concluído'
                if valor_campo != "Processamento concluído":
                    print("Valor diferente de 'Processamento concluído'. Atualizando a página...")
                    self.driver.refresh()
                else:
                    botao_else = self.driver.find_element(By.XPATH, "/html/body/div[3]/form/span/table/tbody/tr[2]/td[4]")
                    botao_else.click()
                    print("Botão ELSE clicado. Encerrando...")
                    break

                time.sleep(3)  # Aguarda um tempo antes de verificar novamente
            except Exception as e:
                print(f"Ocorreu um erro: {e}")
                break

# Execução do script
exportar = ExportarBase()
exportar.abrir_site()
exportar.fazer_login()
exportar.solicitar_export()
exportar.baixar_export()

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
            novo_nome = os.path.join(download_dir, "DENGON2025.dbf")
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

#try:
    # Executa o script R
    #subprocess.run(["Rscript", "C:\\Users\\Jadson Raphael\\Documents\\Python - Arquivos\\python vscode\\Automacao_Tabulacao\\analise_dengon_auto.R"], check=True)
    
    # Se o primeiro rodar com sucesso, executa o script Python
    #subprocess.run(["python", "C:\\Users\\Jadson Raphael\\Documents\\Python - Arquivos\\python vscode\\Automacao_Tabulacao\\Email.py"], check=True)

    #print("Ambos os scripts foram executados com sucesso!")

#except subprocess.CalledProcessError as e:
    #print(f"Erro ao executar um dos scripts: {e}")

input("Pressione Enter para fechar...")
