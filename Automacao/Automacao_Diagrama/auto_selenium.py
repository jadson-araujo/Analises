import os
import datetime
import time
import subprocess
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
        # Insira aqui o seu usuário do SINAN ONLINE
        self.USERNAME = "************"
        # Insira aqui sua senha
        self.PASSWORD = "************"
        # Defina que será usado para a seleção de dados
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
                    EC.presence_of_element_located((By.ID, "form:j_id68:0:j_id79"))
                )
                valor_campo = campo.text
                print(f"Valor atual do campo: {valor_campo}")

                # Condição para atualizar a página se o valor for diferente de 'Processamento concluído'
                if valor_campo != "Processamento concluído":
                    print("Valor diferente de 'Processamento concluído'. Atualizando a página...")
                    self.driver.refresh()
                else:
                    botao_else = self.driver.find_element(By.ID, "form:j_id68:0:j_id92")
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

# Executa o outro arquivo Python
subprocess.run(["python", "C:\\Users\\Jadson Raphael\\Documents\\Python - Arquivos\\python vscode\\Automacao_Diagrama\\extracao.py"])


input("Pressione Enter para fechar...")
