# Teste rápido do protótipo 0.4 (para iniciantes)

Não é necessário mexer no código. Abra o jogo no Godot 4 e pressione **F5**.

| Teste | Como verificar | Esperado |
|---|---|---|
| 1 — Abrir | Abrir `project.godot` e F5 | Inicia a Rua das Acácias, sem mensagens vermelhas |
| 2 — Direções | Andar com W/A/S/D e setas | A garota move-se nos quatro sentidos; o sprite vira |
| 3 — Física | Andar contra casa, árvore e banco | A personagem para no obstáculo, em vez de atravessá-lo |
| 4 — Praça | Andar para a **esquerda** da rua | Entra na praça |
| 5 — Dona Maria | Chegar perto do banco e apertar E | Conversa e recebe missão do gato |
| 6 — Peixaria | Voltar à rua, chegar na porta e apertar E | Entra na peixaria; E perto do peixeiro entrega peixe |
| 7 — Sair da peixaria | Ir até a parte de baixo | Retorna à Rua das Acácias |
| 8 — Terreno | Pela direita da rua até a viela, depois direita novamente | Entra no terreno e precisa chegar perto dos caixotes para encontrar Mingau |
| 9 — Combate | Interagir com Mingau | Menu AGIR, ITEM, CHAMAR, RESGATAR; a esquiva funciona |
| 10 — Resgate | ITEM com peixe → AGIR → RESGATAR | Aparecem os três filhotes e conclui o resgate |
| 11 — Entrega | Voltar à praça e falar com Dona Maria | Recebe pista sobre ônibus e pessoa misteriosa |
| 12 — Caderninho | J no mapa depois da conversa | Pista registrada |
| 13 — Voltar às áreas | Cruzar bordas esquerda/direita | Trocas de tela não causam teleporte para dentro de prédios |

## Se der erro
- Tire uma captura da aba **Depurador / Erros** do Godot (ou copie a primeira mensagem vermelha).
- Informe em qual mapa estava e qual tecla apertou.
- Não altere os arquivos manualmente: envie o erro para corrigirmos a versão do GitHub.

**Observação:** esse roteiro é um teste manual *a realizar*, não uma declaração de que todas as etapas foram aprovadas.
