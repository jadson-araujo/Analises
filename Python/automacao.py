import pandas as pd
import pyautogui
import time
import datetime

# Obtém a data atual
data_atual = datetime.date.today()

# Obtém o número da semana epidemiológica
semana_epidemiologica = data_atual.isocalendar()[1]
semana_epi = str(semana_epidemiologica)

# Automzação do download de bases de dados
pyautogui.PAUSE = 0.9

# 1º Passo: Abrir o navegador
pyautogui.press("win")
pyautogui.write("chrome")
pyautogui.press('Enter')

# 2º Passo: Fazer o login no sinan online
pyautogui.write('https://sinan.saude.gov.br/sinan/login/login.jsf')
pyautogui.press('Enter')
pyautogui.click(x=235, y=450)
pyautogui.write('raissaemanuely')
pyautogui.press('tab')
pyautogui.write('raissa1902')
pyautogui.press('Enter')

# 3º Passo: Solicitar a exportação de dados
pyautogui.click(x=859, y=260)
pyautogui.click(x=930, y=277)
pyautogui.click(x=112, y=415)
pyautogui.click(x=140, y=474)
pyautogui.click(x=423, y=416)
pyautogui.write('2025')
pyautogui.press('tab')
pyautogui.write('1')
pyautogui.press('tab')
pyautogui.write(semana_epi)
pyautogui.press('tab') 
pyautogui.click(x=1136, y=413)
pyautogui.click(x=1107, y=528)
pyautogui.click(x=895, y=562)
time.sleep(10)

# 4º Passo: Baixar a exportação de dados
pyautogui.click(x=859, y=260)
pyautogui.click(x=888, y=365)
time.sleep(5)
pyautogui.click(x=1706, y=385)

