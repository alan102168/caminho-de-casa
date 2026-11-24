# Caminho de Casa 🇧🇷

Protótipo de RPG 2D brasileiro feito no **Godot 4**.

A protagonista se perdeu e procura pistas para encontrar o caminho de volta para casa. Na primeira missão, a garota encontra Dona Maria **sentada num banco da praça, alimentando os pombos**. Ela pede ajuda para resgatar seu gato Mingau de um terreno do bairro. O gato precisa confiar nela antes de ser resgatado.

## Como jogar no Windows

1. Instale o Godot 4 em https://godotengine.org/download/.
2. Na página do repositório, clique em **Code > Download ZIP**.
3. Extraia o ZIP do repositório no seu PC.
4. Abra o Godot, clique em **Importar** e selecione `project.godot`.
5. Pressione **F5** para executar o protótipo.

## Controles

- **WASD / setas**: andar pelo bairro; desviar na batalha.
- **E**: interagir com personagens e objetos próximos.
- **Enter / Espaço / Z**: avançar diálogo e selecionar ações.
- **J**: abrir/fechar o caderninho.
- **Esc**: fechar o caderno ou sair da batalha.

## O que há no protótipo

- Exploração de áreas conectadas de um bairro brasileiro, inclusive a praça com Dona Maria.
- Conversa com Dona Maria e com o peixeiro.
- Peixe como item para conquistar a confiança do Mingau.
- Batalha de esquiva com comandos **AGIR**, **ITEM**, **CHAMAR** e **RESGATAR**.
- Revelação dos três filhotinhos e resgate sem machucar o gato.
- Primeira pista no caderninho, com uma ponta de mistério.

**Versão experimental:** os desenhos e cenários são provisórios. Não há salvamento nem arte final, e ainda precisamos testar no Godot instalado no PC.

Este é um jogo original que usa ideias comuns de RPGs com combate por turnos e esquiva. Não reutiliza assets de outros jogos.

## Versão experimental 0.3 — melhorias visuais e física

- Agora existem **cinco cenários distintos**, com ruas, praça, peixaria, viela e terreno baldio.
- A protagonista usa **WASD ou setas em quatro direções**, com sprites para frente, costas e lados.
- A movimentação usa **CharacterBody2D** e obstáculos **StaticBody2D**: prédios, bancos e entulho têm colisões.
- Mingau agora é um **sprite pixel art PNG**, menor no mapa e ampliado somente no combate.
- Dona Maria continua sentada na praça, alimentando os pombos; não há missão na casa dela.

**Aviso:** versão experimental ainda não executada no Godot neste ambiente. Use um download novo do projeto e importe `project.godot`. Se aparecer erro ao rodar, mande uma captura da aba Erros do Godot.
