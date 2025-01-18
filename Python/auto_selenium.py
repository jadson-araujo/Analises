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

        # Obtém a data atual e calcula a semana epidemiológica
        data_atual = datetime.date.today()
        self.SEMANA_EPI = str(data_atual.isocalendar()[1])  # Convertido para string para evitar erro no send_keys()

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
        WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.ID, "form:username")))
        time.sleep(15)  # Pequena pausa extra para evitar erro de carregamento

    def fazer_login(self):
        # Localiza e preenche o campo de usuário
        campo_usuario = self.driver.find_element(By.ID, "form:username")
        campo_usuario.send_keys(self.USERNAME)

        # Localiza e preenche o campo de senha
        campo_senha = self.driver.find_element(By.ID, "form:password")
        campo_senha.send_keys(self.PASSWORD)

        # Pressiona "Enter" para fazer login
        campo_senha.send_keys(Keys.ENTER)

    def solicitar_export(self):
        # Espera até que o menu da toolbar esteja visível e clica nele
        menu_toolbar = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.ID, "barraMenu:j_id52_span"))
        )
        menu_toolbar.click()

        # Aguarda até que a opção desejada esteja visível e clica nela
        opcao = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//*[@id='barraMenu:j_id53:anchor']"))
        )
        opcao.click()

        # Espera até o campo select ser carregado e seleciona a opção "Semana Epidemiológica"
        campo_select = WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.ID, "form:consulta_tipoPeriodo"))
        )
        selecao = Select(campo_select)
        selecao.select_by_value("1")  # "1" é o value correto para Semana Epidemiológica

        # Preenche o campo de Ano
        campo_ano = WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.XPATH, "//*[@id='form:ano']"))
        )
        campo_ano.send_keys(self.ANO)

        # Preenche o campo de Semana Epidemiológica Inicial
        campo_semana_inicial = self.driver.find_element(By.ID, "form:semanaInicial")  # Ajuste o ID correto
        campo_semana_inicial.clear()
        campo_semana_inicial.send_keys("1")

        # Preenche o campo de Semana Epidemiológica Final
        campo_semana_final = self.driver.find_element(By.ID, "form:semanaFinal")  # Ajuste o ID correto
        campo_semana_final.clear()
        campo_semana_final.send_keys(self.SEMANA_EPI)

        # Espera até o campo select ser carregado e seleciona a opção "UF - Notificação ou Residência"
        campo_select_uf = WebDriverWait(self.driver, 10).until(
            EC.presence_of_element_located((By.ID, "form:tipoUf"))
        )
        selecao_uf = Select(campo_select_uf)
        selecao_uf.select_by_value("3")  # Ajuste conforme necessário
        
        # Clicar no botão solicitar
        solicitar = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//*[@id='form:j_id128']"))
        )
        solicitar.click()

        WebDriverWait(self.driver, 20).until(
            EC.invisibility_of_element_located((By.ID, "ajaxStatusMPDiv"))
        )
        # Espera até que o menu da toolbar esteja visível e clica nele
        menu_toolbar = WebDriverWait(self.driver, 10).until(
            EC.visibility_of_element_located((By.ID, "barraMenu:j_id52_span"))
        )
        menu_toolbar.click()

        # Aguarda até que a opção desejada esteja visível e clica nela
        opcao = WebDriverWait(self.driver, 10).until(
            EC.element_to_be_clickable((By.XPATH, "//*[@id='barraMenu:j_id56']"))
        )
        opcao.click()
        
    def baixar_export(self):
        
        # Definir a condição esperada
        VALOR_ESPERADO = "Aguardando Processamento"

        while True:
            try:
                # Espera até que o campo seja encontrado
                campo = WebDriverWait(self.driver, 10).until(
                    EC.presence_of_element_located((By.ID, "form:j_id68:0:j_id79"))
                )
                
                valor_campo = campo.text  # Obtém o texto do campo
                print(f"Valor atual do campo: {valor_campo}")

                if valor_campo == VALOR_ESPERADO:
                    # Se o campo tem o valor esperado, clica no botão correto
                    botao_if = self.driver.find_element(By.ID, "form:j_id101")
                    botao_if.click()
                    print("Botão IF clicado")
                else:
                    # Se o valor mudou, clica no outro botão e sai do loop
                    botao_else = self.driver.find_element(By.ID, "form:j_id68:0:j_id92")
                    botao_else.click()
                    print("Botão ELSE clicado. Encerrando...")
                    break  # Sai do loop

                time.sleep(5)  # Aguarda um tempo antes de repetir

            except Exception as e:
                print(f"Ocorreu um erro: {e}")
                break  # Sai do loop em caso de erro

# Execução do script
exportar = ExportarBase()
exportar.abrir_site()
exportar.fazer_login()
exportar.solicitar_export()
exportar.baixar_export()

input("Pressione Enter para fechar...")
