import win32com.client
import os

# Criar a integração com o Outlook
outlook = win32com.client.Dispatch('Outlook.Application')

# Criar um email
email = outlook.CreateItem(0)

# Configurar as informações do e-mail
email.To = "exemplo@gmail.com"
email.Subject = "E-mail automático do Python"
email.HTMLBody = f"""
<p>Teste Diagrama</p>

<p>Abs,</p>
<p>Código Python</p>
"""

# Caminho do anexo
anexo = r"caminho para o arquivo"

# Verifica se o anexo existe antes de enviar
if os.path.exists(anexo):
    email.Attachments.Add(anexo)
else:
    print("Aviso: O arquivo de anexo não foi encontrado.")

# Enviar o e-mail
email.Send()
print("Email Enviado!")

