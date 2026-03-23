■ INSTALAÇÃO E USO
Este recurso é um sistema de loja para mecânica, que depende diretamente do painel administrativo.
Para funcionar corretamente, é obrigatório possuir também:
Painel-Mecanico-Fivem
■■ REQUISITOS
-	Servidor rodando FiveM
-	Node.js instalado (necessário para uso do npm)
-	Terminal (PowerShell, CMD ou similar)
-	Script base da mecânica (Painel Mecânico)
■ INSTALAÇÃO
1.	Baixe os dois recursos:
git clone https://github.com/Katiallz/Fivem-Mechanicshop git clone https://github.com/Katiallz/Painel-Mecanico-Fivem
2.	Instale as dependências:
cd Fivem-Mechanicshop/web-side/web npm install
■■ EXECUÇÃO NO SERVIDOR
-	Coloque ambos os recursos em: resources/[local]/
-	No server.cfg adicione: ensure Painel-Mecanico-Fivem ensure Fivem-Mechanicshop
■ SOBRE O SISTEMA
-	Loja da mecânica integrada ao painel
-	Dados e gerenciamento vêm do Painel Mecânico
■■ IMPORTANTE
-	Este recurso não funciona sozinho
-	É obrigatório ter o Painel-Mecanico-Fivem ativo
-	node_modules não é incluído (use npm install)
-	dist já está pronta para uso
■ LICENÇA
Este recurso é gratuito (free)
✔■ Permitido utilizar em servidores
✔■ Permitido modificar para uso próprio
■ Obrigatório manter os créditos ao autor (Katiaallz)
■ Não é permitido remover ou alterar os créditos
■ Não é permitido revender ou redistribuir sem autorização
