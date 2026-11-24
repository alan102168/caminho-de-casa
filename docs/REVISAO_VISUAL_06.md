# Revisão visual e técnica — Protótipo 0.6

Esta revisão é uma evolução do projeto **Caminho de Casa**. Undertale serviu apenas de referência para clareza e simplicidade de jogos de RPG 2D; sprites, cenários e interfaces não reproduzem os do jogo.

## Alterações aplicadas
- Texturas e cenário em grade retrô, com plantas agrupadas e superfícies limpas.
- Sprite do visitante redesenhado para o mapa na mesma escala do restante; o PNG original foi mantido para o retrato do diálogo.
- Renderização por vizinhança mais próxima, posição arredondada e sombras discretas sob os pés.
- Personagens desenhados em ordem de profundidade pela coordenada Y quando dividem a mesma área.
- Transições com fade curto para evitar corte visual brusco entre mapas.
- Melhor separação entre botões e barra de vida, além de novos ataques em pixel art (novelos de lã).
- Áreas de colisão aproximadas dos prédios, banco e balcão; colisor do NPC visitante.
- Configuração de janela com proporção 16:9 preservada e renderização em viewport.

## Qualidade versus bordas em tela cheia
O projeto usa **viewport 960×540** e escala fracionária para que a janela de 1280×720 fique preenchida, sem grandes bordas vazias. Isso preserva a proporção e a filtragem mais próxima, mas em alguns tamanhos de tela os pixels terão espessura irregular, pois o fator de ampliação não é inteiro. Para pixels exatamente uniformes, no futuro podemos oferecer uma opção de escalonamento inteiro, que poderá introduzir margens.

## Verificação
- A pasta `.github/workflows/` contém um teste automático que instala Godot 4.4.1, importa recursos e executa um roteiro de missão.
- `tests/smoke.gd` percorre os estados essenciais da missão.
- Esses testes verificam importação e lógica, não substituem inspeção visual e jogabilidade no PC.
- **Ainda não foi confirmado um resultado verde desses testes neste atendimento.** Conferir a aba Actions do GitHub e executar F5 no editor.

## Próximas melhorias de arte
- Animações adicionais de olhos, braços e cauda para NPCs;
- Sistema de camadas dedicado para objetos altos que encobrem personagens;
- Texturas individuais de ambientes, com mais detalhes desenhados manualmente;
- Testes visuais em resoluções de tela diferentes.
