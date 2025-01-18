from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import datetime

class ExportarBase:
    def __init__(self):
        self.SITE_LINK = "https://sinan.saude.gov.br/sinan/login/login.jsf"
        self.USERNAME = "raissaemanuely"
        self.PASSWORD = "raissa1902"
        self.ANO = "2025"
        # Obtém a data atual
        data_atual = datetime.date.today()
        # Calcula a semana epidemiológica atual (baseada no padrão ISO)
        self.SEMANA_EPI = data_atual.isocalendar()[1]

        # Caminho do WebDriver
        chrome_driver_path = "C:\\chromedriver.exe"  

        # Criando o serviço do ChromeDriver
        service = Service(chrome_driver_path)

        # Inicializando o WebDriver corretamente
        self.driver = webdriver.Chrome(service=service)

        # Maximiza a janela
        self.driver.maximize_window()
        
    def abrir_site(self):
        self.driver.get(self.SITE_LINK)  # Acessa o site
        # Espera até que o campo de login seja carregado
        WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.ID, "form:username")))  # Aguarda o campo de login
        time.sleep(15)
        
    def fazer_login(self):
        # Localiza e preenche o campo de usuário
        campo_usuario = self.driver.find_element(By.ID, "form:username")
        campo_usuario.send_keys(self.USERNAME)

        # Localiza e preenche o campo de senha
        campo_senha = self.driver.find_element(By.ID, "form:password")
        campo_senha.send_keys(self.PASSWORD)

        # Pressiona "Enter" para fazer login
        campo_senha.send_keys(Keys.ENTER)
        
    def realizar_export(self):
        # Espera até que o menu da toolbar esteja visível e clica nele
        menu_toolbar = WebDriverWait(self.driver, 10).until(EC.element_to_be_clickable((By.ID, "barraMenu:j_id52_span")))
        menu_toolbar.click()

        # Aguarda até que a opção desejada esteja visível e clica nela
        opcao = WebDriverWait(self.driver, 10).until(EC.element_to_be_clickable((By.XPATH, "//*[@id='barraMenu:j_id53:anchor']")))
        opcao.click()

        # Espera até o campo select ser carregado e seleciona a opção "Semana Epidemiológica"
        campo_select = WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.ID, "form:consulta_tipoPeriodo")))
        selecao = Select(campo_select)
        selecao.select_by_value("1")
        
        # Preenche o campo de Ano
        campo_semana = self.driver.find_element(By.ID, "form:ano")  # Ajuste o ID correto
        campo_semana.clear()
        campo_semana.send_keys("1")
        
        # Preenche o campo de Semana Epidemiológica Inicial
        campo_semana = self.driver.find_element(By.ID, "form:semanaInicial")  # Ajuste o ID correto
        campo_semana.clear()
        campo_semana.send_keys("1")
        
        # Preenche o campo de Semana Epidemiológica Final
        campo_semana = self.driver.find_element(By.ID, "form:semanaFinal")  # Ajuste o ID correto
        campo_semana.clear()
        campo_semana.send_keys(self.SEMANA_EPI)
        
        
          
exportar = ExportarBase()
exportar.abrir_site()
exportar.fazer_login()
exportar.realizar_export()

input("Pressione Enter para fechar...")
