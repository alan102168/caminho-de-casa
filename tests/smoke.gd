extends SceneTree
# Roteiro automático de verificação dos sistemas básicos.
# Executar: godot --headless --path . --script res://tests/smoke.gd

var problemas: Array[String] = []

func conferir(condicao: bool, mensagem: String) -> void:
	if not condicao:
		problemas.append(mensagem)
		push_error("FALHOU: " + mensagem)

func _initialize() -> void:
	call_deferred("_rodar")

func _rodar() -> void:
	var pacote: PackedScene = load("res://scenes/main.tscn")
	conferir(pacote != null, "A cena principal precisa abrir")
	if pacote == null:
		quit(1)
		return
	var jogo = pacote.instantiate()
	root.add_child(jogo)
	await process_frame

	conferir(jogo.get("sala") == "rua", "Iniciar na Rua das Acácias")
	conferir((jogo.get("fotos") as Dictionary).size() == 5, "Carregar os cinco mapas")
	for mapa in ["rua", "praca", "peixaria", "viela", "terreno"]:
		var tex: Texture2D = (jogo.get("fotos") as Dictionary)[mapa]
		conferir(tex != null and tex.get_width() > 0, "Textura do mapa " + mapa)

	jogo.set("sala", "praca")
	jogo.set("posicao", Vector2(490, 369))
	jogo.call("interagir")
	conferir(jogo.get("modo") == "dialogo", "Conversar com Dona Maria")
	jogo.call("finalizar_dialogo")
	conferir(jogo.get("missao"), "Receber a missão do gato")

	jogo.set("sala", "peixaria")
	jogo.set("posicao", Vector2(479, 393))
	jogo.call("interagir")
	conferir(jogo.get("modo") == "dialogo", "Conversar com o peixeiro")
	jogo.call("finalizar_dialogo")
	conferir(jogo.get("peixe"), "Receber o peixe")

	jogo.set("sala", "terreno")
	jogo.set("posicao", Vector2(826, 420))
	jogo.call("interagir")
	conferir(jogo.get("modo") == "batalha", "Iniciar a luta contra Mingau")
	jogo.set("selecao", 1)
	jogo.call("comando")
	conferir(jogo.get("peixe_dado") and not jogo.get("peixe"), "Usar o peixe na batalha")
	jogo.set("fase", "menu")
	jogo.set("selecao", 0)
	jogo.call("comando")
	conferir(jogo.get("confianca") >= 2, "Mingau precisa confiar após receber peixe e AGIR")
	jogo.set("fase", "menu")
	jogo.set("selecao", 3)
	jogo.call("comando")
	conferir(jogo.get("modo") == "dialogo", "Resgatar Mingau e filhotes")
	jogo.call("finalizar_dialogo")
	conferir(jogo.get("resgatou"), "Concluir o resgate")

	jogo.set("sala", "praca")
	jogo.set("posicao", Vector2(490, 369))
	jogo.call("interagir")
	conferir(jogo.get("modo") == "dialogo", "Entregar os gatos para Dona Maria")
	jogo.call("finalizar_dialogo")
	conferir(jogo.get("concluiu"), "Registrar a primeira pista")

	if problemas.is_empty():
		print("SUCESSO: mapas, diálogos, peixe, batalha e pistas verificados.")
		quit(0)
	else:
		print("FALHAS: ", problemas)
		quit(1)
