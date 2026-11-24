extends Node2D

# Caminho de Casa - Protótipo 0.4
# Todo o protótipo é desenhado e controlado por este script.
const AREA = Rect2(278, 325, 404, 114)
const COR_TEXTO = Color("fff3df")
const COR_FUNDO = Color("342733")
const COR_BORDA = Color("e6c3a1")
const COR_SELECAO = Color("ffcd68")
const COR_VERDE = Color("9fe0ae")


# Sprites da mesma paleta, com pixels definidos em SVGs de baixa resolução.
var garota: Texture2D = preload("res://assets/pixel/garota_frente_0.svg")
var garota_passo: Texture2D = preload("res://assets/pixel/garota_frente_1.svg")
var garota_costas: Texture2D = preload("res://assets/pixel/garota_costas_0.svg")
var garota_costas_passo: Texture2D = preload("res://assets/pixel/garota_costas_1.svg")
var garota_lado: Texture2D = preload("res://assets/pixel/garota_lado_0.svg")
var garota_lado_passo: Texture2D = preload("res://assets/pixel/garota_lado_1.svg")
var maria: Texture2D = preload("res://assets/pixel/dona_maria.svg")
var peixeiro: Texture2D = preload("res://assets/pixel/seu_ze.svg")
var mingau: Texture2D = preload("res://assets/pixel/mingau.svg")
var pombo: Texture2D = preload("res://assets/pixel/pombo.svg")
# Personagem novo enviado pelo criador do jogo (sprite PNG transparente).
var visitante: Texture2D = preload("res://assets/pixel/visitante.png")
var filhotes: Texture2D = preload("res://assets/pixel/filhotes.svg")

# Cada cena é uma área separada. Use as saídas nas bordas para viajar.
var sala = "rua"
var posicao = Vector2(480, 392)
var direcao_olhar = Vector2(0, 1)
var passos = 0.0
var personagem_fisico: CharacterBody2D
var obstaculos: Array[StaticBody2D] = []
var animacao_personagem = 0.0
var tempo_visual = 0.0
var atraso_saida = 0.0
var mingau_encontrado = false
const ENTRADA_PEIXARIA = Vector2(476, 279)
const POS_MARIA = Vector2(490, 290)
const POS_PEIXEIRO = Vector2(479, 314)
const POS_MINGAU = Vector2(826, 346)
const POS_VISITANTE = Vector2(765, 355)
var salas: Dictionary = {
	"rua": {"nome": "Rua das Acácias", "esquerda": "praca", "direita": "viela", "cima": "peixaria"},
	"praca": {"nome": "Praça da Figueira", "direita": "rua"},
	"peixaria": {"nome": "Peixaria do Zé", "baixo": "rua"},
	"viela": {"nome": "Viela do Campinho", "esquerda": "rua", "direita": "terreno"},
	"terreno": {"nome": "Terreno baldio", "esquerda": "viela"}
}
var fotos: Dictionary = {
	"rua": preload("res://assets/pixel/maps/rua.svg"),
	"praca": preload("res://assets/pixel/maps/praca.svg"),
	"peixaria": preload("res://assets/pixel/maps/peixaria.svg"),
	"viela": preload("res://assets/pixel/maps/viela.svg"),
	"terreno": preload("res://assets/pixel/maps/terreno.svg")
}
var modo = "mundo"
var falas: Array = []
var fala_indice = 0
var ao_terminar = ""
var missao = false
var peixe = false
var peixe_dado = false
var resgatou = false
var concluiu = false
var caderno = false
var aviso = "Aproxime-se e aperte E para conversar."
var confianca = 0
var vida = 5
var selecao = 0
var fase = "menu"
var mensagem = "Mingau observa você, desconfiado."
var coracao = AREA.get_center()
var tempo = 0.0
var proximo_ataque = 0.0
var invulneravel = 0.0
var bolinhas: Array[Dictionary] = []
var sorteio = RandomNumberGenerator.new()

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sorteio.randomize()
	criar_corpo_jogadora()
	criar_colisoes_da_sala()
	queue_redraw()

func criar_corpo_jogadora() -> void:
	# A colisão é nos PÉS da garota, para funcionar como RPG visto de cima.
	personagem_fisico = CharacterBody2D.new()
	personagem_fisico.name = "JogadoraFisica"
	personagem_fisico.collision_layer = 1
	personagem_fisico.collision_mask = 1
	personagem_fisico.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_child(personagem_fisico)
	var formato = CircleShape2D.new()
	formato.radius = 11.0
	var colisao = CollisionShape2D.new()
	colisao.name = "ColisaoDosPes"
	colisao.shape = formato
	colisao.position = Vector2(0, 25)
	personagem_fisico.add_child(colisao)
	personagem_fisico.position = posicao

func criar_colisoes_da_sala() -> void:
	# Paredes, casas, bancos e obstáculos. Não são decoração:
	# a personagem não pode atravessá-los.
	for corpo in obstaculos:
		if is_instance_valid(corpo):
			corpo.collision_layer = 0
			corpo.queue_free()
	obstaculos.clear()
	var areas: Array[Rect2] = []
	match sala:
		"rua":
			areas = [
				Rect2(67, 110, 284, 150), # casa à esquerda
				Rect2(357, 140, 175, 122), # construção ao centro
				Rect2(611, 118, 288, 145), # casa à direita
				Rect2(900, 94, 48, 139) # muro lateral
			]
		"praca":
			areas = [
				Rect2(38, 113, 268, 144),
				Rect2(639, 119, 265, 146),
				Rect2(389, 274, 191, 76), # banco de Dona Maria
				Rect2(298, 229, 33, 65), # árvore esquerda
				Rect2(605, 229, 33, 64) # árvore direita
			]
		"peixaria":
			areas = [
				Rect2(48, 106, 866, 159),
				Rect2(345, 277, 271, 68), # balcão
				Rect2(96, 148, 30, 77),
				Rect2(834, 146, 33, 84)
			]
		"viela":
			areas = [
				Rect2(26, 107, 296, 220),
				Rect2(332, 106, 313, 219),
				Rect2(663, 95, 271, 230),
				Rect2(726, 341, 114, 74)
			]
		"terreno":
			areas = [
				Rect2(9, 87, 269, 164),
				Rect2(274, 92, 424, 154), # muro ao fundo
				Rect2(691, 84, 260, 164),
				Rect2(60, 299, 194, 61), # entulho
				Rect2(652, 258, 132, 43), # madeira empilhada
				Rect2(742, 219, 144, 43),
				Rect2(755, 345, 123, 46) # caixotes perto de Mingau
			]
	for area in areas:
		var corpo = StaticBody2D.new()
		corpo.collision_layer = 1
		corpo.collision_mask = 0
		var forma = RectangleShape2D.new()
		forma.size = area.size
		var colisao = CollisionShape2D.new()
		colisao.shape = forma
		colisao.position = area.get_center()
		corpo.add_child(colisao)
		add_child(corpo)
		obstaculos.append(corpo)

func _physics_process(delta: float) -> void:
	atraso_saida = maxf(0.0, atraso_saida - delta)
	if modo != "mundo" or caderno:
		personagem_fisico.velocity = Vector2.ZERO
		return
	var direcao = eixo()
	if direcao != Vector2.ZERO:
		direcao_olhar = direcao
		animacao_personagem += 0.22
	personagem_fisico.velocity = direcao * 175.0
	personagem_fisico.move_and_slide()
	posicao = personagem_fisico.position
	var sala_anterior = sala
	if atraso_saida <= 0.0:
		transicao_portas()
	posicao.x = clampf(posicao.x, 36.0, 924.0)
	posicao.y = clampf(posicao.y, 111.0, 464.0)
	personagem_fisico.position = posicao
	if sala != sala_anterior:
		atraso_saida = 0.35

func eixo() -> Vector2:
	var direcao = Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direcao.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direcao.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direcao.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direcao.y += 1
	return direcao.normalized()

func _process(delta: float) -> void:
	tempo_visual += delta
	if modo == "mundo" and sala == "terreno" and missao and not resgatou and not mingau_encontrado:
		if posicao.distance_to(POS_MINGAU) < 176.0:
			mingau_encontrado = true
			aviso = "Miau! Tem um gato escondido atrás dos caixotes..."
	if modo == "batalha" and fase == "esquiva":
		processar_esquiva(delta)
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var tecla = event as InputEventKey
	if not tecla.pressed or tecla.echo:
		return
	var codigo = tecla.keycode
	if modo == "dialogo":
		if codigo in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_Z, KEY_E]:
			fala_indice += 1
			if fala_indice >= falas.size():
				finalizar_dialogo()
		return
	if modo == "mundo":
		if codigo == KEY_J:
			caderno = not caderno
		elif codigo == KEY_ESCAPE:
			caderno = false
		elif codigo == KEY_E and not caderno:
			interagir()
	elif modo == "batalha":
		if codigo == KEY_ESCAPE:
			modo = "mundo"
			aviso = "Você saiu do terreno. Mingau continua ali."
		elif fase == "menu":
			if codigo in [KEY_LEFT, KEY_A]:
				selecao = posmod(selecao - 1, 4)
			if codigo in [KEY_RIGHT, KEY_D]:
				selecao = posmod(selecao + 1, 4)
			if codigo in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_Z]:
				comando()

func mudar_area(proxima: String, entrada: Vector2) -> void:
	sala = proxima
	posicao = entrada
	personagem_fisico.position = entrada
	personagem_fisico.velocity = Vector2.ZERO
	atraso_saida = 0.35
	aviso = "Chegou em " + str(salas[sala]["nome"]) + ". Explore com WASD ou setas."
	call_deferred("criar_colisoes_da_sala")

func transicao_portas() -> void:
	# A porta da loja fica na borda inferior; as outras saídas são laterais.
	if sala == "peixaria" and posicao.y > 457.0 and posicao.x > 347.0 and posicao.x < 613.0:
		mudar_area("rua", Vector2(476, 338))
		return
	# Só é possível sair pela calçada (não por dentro de paredes).
	if posicao.y < 348.0 or posicao.y > 454.0:
		return
	var destinos: Dictionary = salas[sala]
	if posicao.x <= 37.0 and destinos.has("esquerda"):
		mudar_area(str(destinos["esquerda"]), Vector2(895, posicao.y))
	elif posicao.x >= 923.0 and destinos.has("direita"):
		mudar_area(str(destinos["direita"]), Vector2(66, posicao.y))


func interagir() -> void:
	if sala == "rua" and posicao.distance_to(POS_VISITANTE) < 91.0:
		dialogo([
			"Garota: Oi! Gostei da sua fantasia!",
			"Visitante: Valeu! Hoje vai ter um encontro de cosplay por aqui.",
			"Visitante: Tá procurando alguém? A Dona Maria costuma ficar na praça, à esquerda."
		], "")
		return
	if sala == "rua" and posicao.distance_to(ENTRADA_PEIXARIA) < 86.0:
		mudar_area("peixaria", Vector2(481, 421))
		return
	if sala == "praca" and posicao.distance_to(POS_MARIA) < 112.0:
		if resgatou and not concluiu:
			dialogo([
				"Dona Maria: Você trouxe Mingau... e três filhotinhos?!",
				"Dona Maria: Vou cuidar de todos. Muito obrigada!",
				"Dona Maria: Seu bairro é na direção do ônibus de faixa azul.",
				"Dona Maria: Ontem passou uma pessoa procurando uma menina igualzinha a você...",
				"Garota: Quem será que estava me procurando?"
			], "final")
		elif concluiu:
			dialogo(["Dona Maria: Vai com cuidado, minha filha! Boa sorte!" ], "")
		elif not missao:
			dialogo([
				"Garota: Oi! A senhora sabe como chego ao meu bairro?",
				"Dona Maria: Conheço sim, menina, mas faz um favor pra mim?",
				"Dona Maria: Meu gato Mingau fugiu para um terreno do bairro.",
				"Dona Maria: Traz ele de volta que te conto o caminho!"
			], "missao")
		else:
			dialogo(["Dona Maria: O bichinho se escondeu num terreno depois da viela. Deve estar com fome."], "")
	elif sala == "peixaria" and posicao.distance_to(POS_PEIXEIRO) < 110.0:
		if not missao:
			dialogo(["Seu Zé: Bom dia! Peixe fresquinho!"], "")
		elif peixe:
			dialogo(["Seu Zé: Boa sorte com o gato, menina!"], "")
		elif peixe_dado:
			dialogo(["Seu Zé: Espero que o Mingau esteja calminho."], "")
		else:
			dialogo([
				"Garota: Moço, arruma um peixe pra um gato assustado?",
				"Seu Zé: Pra ajudar um bichinho? Leva esse aqui!",
				"Garota: Valeu! Vou procurar o Mingau."
			], "peixe")
	elif sala == "terreno" and posicao.distance_to(POS_MINGAU) < 93.0 and not resgatou:
		mingau_encontrado = true
		if not missao:
			dialogo(["* Um gato laranja encara você e se afasta."], "")
		else:
			comecar_batalha()
	else:
		aviso = "Explore o bairro! Fale com moradores usando E."

func dialogo(textos: Array, acao: String) -> void:
	falas = textos
	fala_indice = 0
	ao_terminar = acao
	modo = "dialogo"

func finalizar_dialogo() -> void:
	modo = "mundo"
	match ao_terminar:
		"missao":
			missao = true
			aviso = "Missão: encontrar Mingau, no terreno à direita."
		"peixe":
			peixe = true
			aviso = "Você conseguiu um peixe! Procure Mingau."
		"resgate":
			resgatou = true
			aviso = "Mingau e os filhotes estão seguros. Volte à Dona Maria!"
		"final":
			concluiu = true
			aviso = "Você recebeu uma pista! Aperte J para ler."
	ao_terminar = ""

func comecar_batalha() -> void:
	modo = "batalha"
	fase = "menu"
	selecao = 0
	vida = 5
	mensagem = "Mingau não quer deixar você chegar perto."
	bolinhas.clear()

func comando() -> void:
	match selecao:
		0:
			if confianca == 0:
				iniciar_esquiva("Você tenta se aproximar. Mingau se assusta!")
			elif confianca == 1:
				confianca = 2
				iniciar_esquiva("Você fala com calma. Mingau começa a confiar!")
			else:
				iniciar_esquiva("Mingau ronrona baixinho. Parece pronto!")
		1:
			if peixe:
				peixe = false
				peixe_dado = true
				confianca = maxi(confianca, 1)
				iniciar_esquiva("Você oferece o peixe. Mingau come e relaxa!")
			else:
				iniciar_esquiva("Não há peixe na mochila. ESC para sair da batalha.")
		2:
			iniciar_esquiva("Pss pss! Mingau responde com um miado.")
		3:
			if confianca >= 2:
				dialogo([
					"* Mingau finalmente permite que você se aproxime.",
					"* Três filhotinhos saem de trás de uma caixa!",
					"Garota: Então era por isso que você não queria sair!",
					"* Você recolhe os quatro com cuidado, sem machucá-los.",
					"* Volte à Dona Maria."
				], "resgate")
			else:
				iniciar_esquiva("Mingau ainda não confia em você.")

func iniciar_esquiva(texto_atual: String) -> void:
	mensagem = texto_atual
	fase = "esquiva"
	tempo = 4.0
	proximo_ataque = 0.0
	coracao = AREA.get_center()
	bolinhas.clear()

func processar_esquiva(delta: float) -> void:
	tempo -= delta
	invulneravel = maxf(0.0, invulneravel - delta)
	coracao += eixo() * 240.0 * delta
	coracao.x = clampf(coracao.x, AREA.position.x + 14.0, AREA.end.x - 14.0)
	coracao.y = clampf(coracao.y, AREA.position.y + 14.0, AREA.end.y - 14.0)
	proximo_ataque -= delta
	if proximo_ataque <= 0.0:
		proximo_ataque = 0.55
		var esquerda = sorteio.randf() < 0.5
		var x = AREA.position.x - 18.0 if esquerda else AREA.end.x + 18.0
		var y = sorteio.randf_range(AREA.position.y + 15.0, AREA.end.y - 15.0)
		var velocidade = 165.0 if esquerda else -165.0
		bolinhas.append({"pos": Vector2(x, y), "vel": Vector2(velocidade, 0)})
	for i in range(bolinhas.size() - 1, -1, -1):
		var bola = bolinhas[i]
		var ponto: Vector2 = bola["pos"]
		ponto += bola["vel"] * delta
		bola["pos"] = ponto
		if ponto.x < AREA.position.x - 50.0 or ponto.x > AREA.end.x + 50.0:
			bolinhas.remove_at(i)
		elif ponto.distance_to(coracao) < 16.0 and invulneravel <= 0.0:
			vida -= 1
			invulneravel = 0.85
	if vida <= 0:
		fase = "menu"
		vida = 5
		bolinhas.clear()
		mensagem = "Você se atrapalhou! Pode tentar de novo."
	elif tempo <= 0.0:
		fase = "menu"
		bolinhas.clear()
		if confianca >= 2:
			mensagem = "Mingau está tranquilo. Você já pode resgatá-lo!"

func fonte() -> Font:
	return ThemeDB.fallback_font

func escrever(msg: String, x: float, y: float, tamanho: int = 20, cor: Color = COR_TEXTO) -> void:
	draw_string(fonte(), Vector2(x + 1, y + 2), msg, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho, Color("201820"))
	draw_string(fonte(), Vector2(x, y), msg, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho, cor)

func caixa(area: Rect2, fundo: Color = COR_FUNDO, borda: Color = COR_BORDA) -> void:
	draw_rect(area, fundo)
	draw_rect(area, borda, false, 3.0)

func retrato(tex: Texture2D, centro: Vector2, dimensao: Vector2) -> void:
	draw_texture_rect(tex, Rect2(centro - dimensao / 2.0, dimensao), false)

func retrato_personagem(tex: Texture2D, centro: Vector2, dimensao: Vector2, virar: bool) -> void:
	var rect = Rect2(centro - dimensao / 2.0, dimensao)
	if virar:
		draw_set_transform(Vector2(rect.position.x + rect.size.x, rect.position.y), 0.0, Vector2(-1, 1))
		draw_texture_rect(tex, Rect2(0, 0, rect.size.x, rect.size.y), false)
		draw_set_transform(Vector2.ZERO)
	else:
		draw_texture_rect(tex, rect, false)

func _draw() -> void:
	if modo == "batalha" or (modo == "dialogo" and ao_terminar == "resgate"):
		desenhar_batalha()
	else:
		desenhar_mundo()
	if modo == "dialogo":
		desenhar_dialogo()
	if modo == "mundo" and caderno:
		desenhar_caderno()

func objetivo() -> String:
	if concluiu:
		return "Objetivo: quem era a pessoa procurando a garota? (fim do protótipo)"
	if resgatou:
		return "Objetivo: devolver Mingau e os filhotes à Dona Maria."
	if not missao:
		return "Objetivo: encontre Dona Maria sentada na praça, alimentando pombos."
	if peixe or peixe_dado:
		return "Objetivo: procure Mingau no terreno depois da viela."
	return "Objetivo: procure a peixaria na parte alta da rua."

func desenhar_mundo() -> void:
	draw_texture_rect(fotos[sala], Rect2(0, 0, 960, 540), false)
	if sala == "rua":
		retrato(visitante, POS_VISITANTE, Vector2(60, 91))
		if posicao.distance_to(POS_VISITANTE) < 100.0:
			escrever("E: conversar", 695, 286, 16, COR_SELECAO)
	if sala == "praca":
		# Dona Maria sentada no banco da praça; pombos se movimentam perto da comida.
		retrato(maria, Vector2(489, 285), Vector2(53, 59))
		for i in range(4):
			var p = Vector2(355 + i * 66, 384 + int(sin(tempo_visual * 2.5 + i * 3) * 4))
			retrato(pombo, p, Vector2(34, 24))
	elif sala == "peixaria":
		retrato(peixeiro, POS_PEIXEIRO, Vector2(52, 64))
	elif sala == "terreno" and not resgatou and mingau_encontrado:
		# Gato pequeno e parcialmente escondido: o jogador precisa chegar até ele.
		retrato(mingau, POS_MINGAU, Vector2(51, 37))
		draw_rect(Rect2(809, 370, 76, 14), Color("796755"))
		draw_rect(Rect2(805, 366, 82, 5), Color("b59b79"))
	# A animação indica passos e uma pose diferente ao olhar para cada lado.
	var andando = personagem_fisico.velocity.length() > 0.1 and modo == "mundo"
	var passo = andando and (int(animacao_personagem * 0.9) % 2 == 1)
	var sprite: Texture2D = garota_passo if passo else garota
	if direcao_olhar.y < -0.45:
		sprite = garota_costas_passo if passo else garota_costas
	elif absf(direcao_olhar.x) > 0.45:
		sprite = garota_lado_passo if passo else garota_lado
	var espelhar = direcao_olhar.x < -0.45
	retrato_personagem(sprite, posicao + Vector2(0, -7), Vector2(51, 76), espelhar)
	# Portais discretos nas bordas do mapa.
	var destinos: Dictionary = salas[sala]
	if destinos.has("esquerda"):
		escrever("<", 8, 406, 26, COR_SELECAO)
	if destinos.has("direita"):
		escrever(">", 931, 406, 26, COR_SELECAO)
	if sala == "rua" and posicao.distance_to(ENTRADA_PEIXARIA) < 135.0:
		escrever("E: entrar na peixaria", 370, 302, 17, COR_SELECAO)
	if sala == "peixaria":
		escrever("SAÍDA", 429, 453, 18, COR_SELECAO)
	caixa(Rect2(12, 8, 936, 78), Color("3b2a35"), Color("ffe1ab"))
	escrever(salas[sala]["nome"].to_upper(), 26, 36, 23, COR_SELECAO)
	escrever(objetivo(), 26, 65, 16)
	escrever("PEIXE: " + ("1" if peixe else "0"), 790, 35, 18, COR_SELECAO)
	caixa(Rect2(15, 484, 930, 46), Color("3b2a35"), Color("ffe1ab"))
	escrever(aviso, 30, 514, 17)

func desenhar_dialogo() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color(0, 0, 0, 0.32))
	caixa(Rect2(44, 358, 872, 160), Color("2e222f"), Color("f3d3aa"))
	var texto_atual = falas[mini(fala_indice, falas.size() - 1)]
	var linhas = quebrar(texto_atual, 70)
	for i in range(mini(3, linhas.size())):
		escrever(linhas[i], 67, 399 + 30 * i, 20)
	escrever("ENTER / ESPAÇO para continuar  >", 607, 499, 15, COR_SELECAO)

func quebrar(frase: String, limite: int) -> Array[String]:
	var linhas: Array[String] = []
	var atual = ""
	for parte in frase.split(" "):
		if atual.length() + parte.length() + 1 > limite and atual != "":
			linhas.append(atual)
			atual = parte
		else:
			atual += (" " if atual != "" else "") + parte
	if atual != "":
		linhas.append(atual)
	return linhas

func desenhar_batalha() -> void:
	draw_texture_rect(fotos["terreno"], Rect2(0, 0, 960, 540), false)
	draw_rect(Rect2(0, 290, 960, 250), Color("423740"))
	retrato(mingau, Vector2(480, 151), Vector2(184, 137))
	if modo == "dialogo" and ao_terminar == "resgate" and fala_indice >= 1:
		retrato(filhotes, Vector2(618, 203), Vector2(126, 39))
	escrever("MINGAU", 39, 43, 26, COR_SELECAO)
	escrever("Confiança: " + str(confianca) + "/2", 719, 43, 19, COR_VERDE)
	caixa(Rect2(43, 232, 874, 63))
	var linhas = quebrar(mensagem, 86)
	for i in range(mini(linhas.size(), 2)):
		escrever(linhas[i], 63, 261 + 24 * i, 19)
	caixa(AREA, Color("2b2132"), Color("dabfcc"))
	if fase == "esquiva":
		for bola in bolinhas:
			draw_circle(bola["pos"], 8, Color("eac48b"))
			draw_arc(bola["pos"], 8, 0.0, TAU, 12, Color("8a634a"), 2.0)
		if invulneravel <= 0.0 or int(invulneravel * 12.0) % 2 == 0:
			desenhar_coracao()
		escrever("Desvie das bolinhas de lã!   " + str(maxi(0, ceili(tempo))) + "s", 318, 466, 17, COR_SELECAO)
	else:
		escrever("Escolha uma ação para ajudar Mingau.", 308, 377, 19)
	escrever("PV: " + str(vida) + "/5", 42, 469, 19, COR_VERDE)
	var botoes = ["AGIR", "ITEM", "CHAMAR", "RESGATAR"]
	for i in range(4):
		var x = 24.0 + i * 236.0
		var marcado = i == selecao
		var cor_borda = COR_SELECAO if marcado else Color("cdb4b8")
		if i == 3 and confianca >= 2:
			cor_borda = COR_VERDE
		caixa(Rect2(x, 482, 216, 46), Color("63414c") if marcado else Color("40313d"), cor_borda)
		escrever(botoes[i], x + 21, 510, 21, COR_SELECAO if marcado else COR_TEXTO)

func desenhar_coracao() -> void:
	for pedaco in [Rect2(-9, -6, 8, 7), Rect2(1, -6, 8, 7), Rect2(-11, 0, 22, 6), Rect2(-8, 6, 16, 5), Rect2(-4, 11, 8, 5)]:
		draw_rect(Rect2(coracao + pedaco.position, pedaco.size), Color("f66374"))

func desenhar_caderno() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color(0, 0, 0, 0.68))
	caixa(Rect2(154, 58, 652, 419), Color("e6d5ad"), Color("7a5746"))
	var tinta = Color("563942")
	escrever("CADERNINHO", 187, 109, 30, tinta)
	escrever("MINHAS PISTAS", 187, 160, 21, tinta)
	if concluiu:
		escrever("1. O ônibus do bairro tem uma faixa azul.", 190, 204, 18, tinta)
		escrever("2. Alguém procurava uma garota igual a mim!", 190, 243, 18, tinta)
	else:
		escrever("Ainda não tenho nenhuma pista definitiva...", 190, 204, 18, tinta)
	escrever("MISSÃO DO MINGAU", 187, 311, 21, tinta)
	var status = "Concluída" if resgatou else "Em andamento" if missao else "Não iniciada"
	escrever(status, 191, 350, 19, tinta)
	escrever("Pressione J ou ESC para fechar", 189, 438, 17, tinta)
