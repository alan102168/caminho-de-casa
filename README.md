# Caminho de Casa 🇧🇷 — Protótipo 0.5

RPG 2D brasileiro sobre uma garota perdida que tenta voltar para casa. A primeira missão é ajudar Dona Maria, sentada na praça dando comida aos pombos, a resgatar Mingau e seus três filhotes.

**Motor:** Godot 4 (GDScript). **Estado:** versão experimental com arte provisória refinada e exploração em cinco áreas. O protótipo **ainda precisa ser testado no Godot instalado no PC**.

## 📥 Como abrir no Windows (sem saber programar)

1. Na página do GitHub, clique em **Code → Download ZIP**.
2. Extraia tudo em uma pasta nova (não misture com uma versão antiga).
3. Instale ou abra o [Godot 4](https://godotengine.org/download/windows/).
4. Clique em **Importar**, selecione o arquivo `project.godot` dentro da pasta extraída.
5. Abra o projeto e pressione **F5**. Espere os recursos importarem na primeira execução.

## 🎮 Controles

| Tecla | Ação |
|---|---|
| **WASD / Setas** | Andar para cima, baixo, esquerda e direita; esquivar na batalha |
| **E** | Conversar, examinar o gato, entrar na peixaria pela porta |
| **Enter / Espaço / Z** | Avançar conversas e confirmar ação de combate |
| **← / →** | Trocar de opção na batalha |
| **J** | Abrir ou fechar caderninho de pistas |
| **Esc** | Fechar o caderninho ou abandonar uma batalha |

## 🗺️ Como explorar

- **Rua das Acácias:** ponto inicial. Saída esquerda vai para a **Praça da Figueira**; direita vai para a **Viela do Campinho**.
- **Praça:** Dona Maria está sentada no banco, perto dos pombos.
- **Peixaria:** na Rua das Acácias, aproxime-se da entrada e aperte **E**. Lá dentro, converse com Seu Zé para conseguir um peixe. Para sair, desça pela parte de baixo.
- **Viela:** pela direita da rua; segue para o terreno baldio.
- **Terreno:** encontre Mingau perto dos caixotes, no fundo do terreno.

## 🐈 Primeira missão

1. Fale com Dona Maria na praça.
2. Volte à rua, entre na peixaria e pegue um peixe.
3. Atravesse a viela, procure Mingau no terreno e interaja com **E**.
4. Na batalha, use **ITEM** para oferecer o peixe; depois **AGIR** para tranquilizá-lo.
5. Quando ele confiar, escolha **RESGATAR**. Ele estava protegendo três filhotes.
6. Volte à praça, converse com Dona Maria e registre a pista no caderninho com **J**.

## 🧩 Estrutura

- `project.godot`: configuração do projeto Godot.
- `scenes/main.tscn`: cena principal.
- `scripts/main.gd`: exploração, colisões, interações, combate e missões.
- `assets/pixel/maps/`: cinco cenários desenhados em baixa resolução.
- `assets/pixel/`: personagens, Mingau e filhotes no mesmo estilo pixel art.
- `docs/`: planejamento e testes manuais.

## ⚠️ Qualidade e testes

Nesta revisão foram corrigidos problemas de transição, colocada uma entrada interativa na peixaria, criada física por colisões e refeitos os recursos visuais na mesma paleta e resolução. **Ainda não consegui executar o Godot neste ambiente**; portanto, não estou afirmando que está livre de bugs. O roteiro de testes está em `docs/TESTES.md`. Se aparecer um erro, envie a primeira linha vermelha do painel de erros do Godot.

O projeto usa mecânicas gerais de RPG com escolha e esquiva, mas seus personagens, história e arte devem ser originais.

## Atualização visual 0.5 — retrô brasileiro

- Os cinco mapas foram redesenhados com **grandes áreas de cor sólida**, estilo RPG retrô minimalista.
- Removidos os pontinhos e texturas aleatórias que poluíam as ruas, a praça e o terreno.
- Vegetação apenas em grupos definidos, sem espalhar pixels verdes pelo chão.
- Calçadas, asfalto, muros, casas e portas mais legíveis, com contornos de alto contraste.
- Interface do mapa e da batalha simplificada, preservando os sistemas e as falas.
- Ambientação continua brasileira e todos os gráficos são próprios; nenhuma imagem de Undertale foi copiada.

**Teste importante:** baixe um ZIP novo, extraia em pasta nova e reimporte `project.godot`. Esta revisão não foi executada no editor Godot neste ambiente.
