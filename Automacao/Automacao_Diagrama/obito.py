import pandas as pd

# Adicione um 'r' antes da string para evitar problemas com barras invertidas
caminho_arquivo = r"C:\Users\Jadson Raphael\Documents\Python - Arquivos\python vscode\Automacao_Diagrama\\DengueDistribuicaoPorObito.xlsx"

# Ler o arquivo Excel
obitos_df = pd.read_excel(caminho_arquivo)

# Mostrar as primeiras linhas para conferir
print(obitos_df.head())
