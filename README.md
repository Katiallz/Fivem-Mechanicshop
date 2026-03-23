📥 Instalação e Uso

Este recurso é um sistema de loja para mecânica, que depende diretamente do painel administrativo.

Para funcionar corretamente, é obrigatório possuir também:
👉 Painel-Mecanico-Fivem


⚙️ Requisitos
Servidor rodando FiveM

Node.js instalado (necessário para uso do npm)

Terminal (PowerShell, CMD ou similar)

Script base da mecânica (Painel Mecânico)

🚀 Instalação
1. Baixe os dois recursos

git clone https://github.com/Katiallz/Fivem-Mechanicshop

git clone https://github.com/Katiallz/Painel-Mecanico-Fivem

2. Instale as dependências (frontend da loja)

cd Fivem-Mechanicshop/web-side/web

npm install

▶️ Execução no Servidor

Coloque ambos os recursos em:
resources/[local]/
No seu server.cfg, adicione:

ensure Painel-Mecanico-Fivem

ensure Fivem-Mechanicshop

📌 Sobre o Sistema
Este script é responsável pela loja da mecânica
O gerenciamento e dados vêm do Painel Mecânico
Ambos funcionam de forma integrada


⚠️ Importante
Este recurso não funciona sozinho
É obrigatório ter o Painel-Mecanico-Fivem ativo
A pasta node_modules não é incluída (use npm install)
A pasta dist já está pronta para uso

🆓 Licença

Este recurso é gratuito (free) para uso.

✔️ Permitido utilizar em servidores
✔️ Permitido modificar para uso próprio
❌ Obrigatório manter os créditos ao autor (Katiaallz)
❌ Não é permitido remover ou alterar os créditos
❌ Não é permitido revender ou redistribuir sem autorização
