import win32com.client
import os

with open("situacao.txt", "r") as file:
    situacao = file.read().strip()
with open("ultima_semana.txt", "r") as file:
    ultima_semana = file.read().strip()

# Criar a integração com o Outlook
outlook = win32com.client.Dispatch('Outlook.Application')

# Criar um email
email = outlook.CreateItem(0)

# Configurar as informações do e-mail
email.To = "example@email.com"
#email.To = "example@email.com"
email.Subject = "Envio de Dados para Construção do Diagrama de Controle"
email.HTMLBody = f"""
<p>Prezado(a),</p>

<p>Gostaria de informar que, referente à semana {ultima_semana}, a situação atual indica que {situacao}.</p>

<p>Em anexo, seguem os dados necessários para a construção do diagrama de controle.</p>

<p>Este e-mail foi enviado automaticamente.</p>


<p>Atenciosamente,</p>
<p>Jadson Raphael Silva de Araujo</p>
"""


# Caminho do anexo
anexo = r"C:\\Users\\Jadson Raphael\\Documents\\Python - Arquivos\\python vscode\\PARA O DIAGRAMA.xlsx"

# Verifica se o anexo existe antes de enviar
if os.path.exists(anexo):
    email.Attachments.Add(anexo)
else:
    print("Aviso: O arquivo de anexo não foi encontrado.")

# Enviar o e-mail
email.Send()
print("Email Enviado!")

