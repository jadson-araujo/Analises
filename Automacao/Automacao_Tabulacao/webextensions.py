from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

# Configurações do navegador
chrome_options = webdriver.ChromeOptions()

# Baixa e usa o ChromeDriver correto automaticamente
service = Service(ChromeDriverManager().install())

# Inicia o WebDriver
driver = webdriver.Chrome(service=service, options=chrome_options)

driver.get("https://www.google.com")  # Teste de funcionamento
