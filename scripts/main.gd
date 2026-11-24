extends Node2D

# Caminho de Casa - Protótipo 0.1
# Todo o protótipo é desenhado e controlado por este script.
const AREA = Rect2(278, 325, 404, 114)
const COR_TEXTO = Color("fff3df")
const COR_FUNDO = Color("342733")
const COR_BORDA = Color("e6c3a1")
const COR_SELECAO = Color("ffcd68")
const COR_VERDE = Color("9fe0ae")

var bairro: Texture2D = preload("res://assets/bairro.svg")
var terreno: Texture2D = preload("res://assets/terreno.svg")
var garota: Texture2D = preload("res://assets/garota.svg")
var garota_costas: Texture2D = preload("res://assets/garota_costas.svg")
var garota_lado: Texture2D = preload("res://assets/garota_lado.svg")
var maria: Texture2D = preload("res://assets/maria.svg")
var peixeiro: Texture2D = preload("res://assets/peixeiro.svg")
var mingau: Texture2D = preload("res://assets/mingau_pixel.png")
var filhotes: Texture2D = preload("res://assets/filhotes.svg")

# Cada cena é uma área separada. Use as saídas nas bordas para viajar.
var sala = "rua"
var posicao = Vector2(480, 392)
var direcao_olhar = Vector2(0, 1)
var passos = 0.0
var personagem_fisico: CharacterBody2D
var obstaculos: Array[StaticBody2D] = []
var animacao_personagem = 0.0
const POS_MARIA = Vector2(490, 290)
const POS_PEIXEIRO = Vector2(479, 314)
const POS_MINGAU = Vector2(830, 346)
var salas: Dictionary = {
	"rua": {"nome": "Rua das Acácias", "esquerda": "praca", "direita": "viela", "cima": "peixaria"},
	"praca": {"nome": "Praça da Figueira", "direita": "rua"},
	"peixaria": {"nome": "Peixaria do Zé", "baixo": "rua"},
	"viela": {"nome": "Viela do Campinho", "esquerda": "rua", "direita": "terreno"},
	"terreno": {"nome": "Terreno baldio", "esquerda": "viela"}
}
var fotos: Dictionary = {
	"rua": preload("res://assets/maps/rua.svg"),
	"praca": preload("res://assets/maps/praca.svg"),
	"peixaria": preload("res://assets/maps/peixaria.svg"),
	"viela": preload("res://assets/maps/viela.svg"),
	"terreno": preload("res://assets/maps/terreno.svg")
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
				Rect2(409, 278, 167, 72), # banco de Dona Maria
				Rect2(349, 215, 30, 52), # tronco
				Rect2(570, 207, 27, 54), # tronco
				Rect2(428, 303, 104, 49) # chafariz
			]
		"peixaria":
			areas = [
				Rect2(220, 110, 533, 172),
				Rect2(363, 282, 236, 58), # balcão
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
				Rect2(691, 84, 260, 164),
				Rect2(60, 299, 194, 61), # entulho
				Rect2(652, 258, 132, 43), # madeira empilhada
				Rect2(742, 219, 144, 43)
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

func _physics_process(_delta: float) -> void:
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
	transicao_portas()
	posicao.x = clampf(posicao.x, 36.0, 924.0)
	posicao.y = clampf(posicao.y, 111.0, 464.0)
	personagem_fisico.position = posicao
	if sala != sala_anterior:
		call_deferred("criar_colisoes_da_sala")

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

func transicao_portas() -> void:
	var destinos: Dictionary = salas[sala]
	if posicao.x < 37.0 and destinos.has("esquerda"):
		sala = destinos["esquerda"]
		posicao = Vector2(894, clampf(posicao.y, 376.0, 425.0))
		aviso = "Você entrou em " + salas[sala]["nome"] + "."
	elif posicao.x > 923.0 and destinos.has("direita"):
		sala = destinos["direita"]
		posicao = Vector2(65, clampf(posicao.y, 376.0, 425.0))
		aviso = "Você entrou em " + salas[sala]["nome"] + "."
	elif posicao.y < 112.0 and destinos.has("cima") and posicao.x > 340 and posicao.x < 620:
		sala = destinos["cima"]
		posicao = Vector2(480, 426)
		aviso = "Você entrou em " + salas[sala]["nome"] + "."
	elif posicao.y > 463.0 and destinos.has("baixo") and posicao.x > 340 and posicao.x < 620:
		sala = destinos["baixo"]
		posicao = Vector2(573, 298)
		aviso = "Você entrou em " + salas[sala]["nome"] + "."

func interagir() -> void:
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
	if sala == "praca":
		# Dona Maria fica sentada no banco da praça, alimentando os pombos.
		retrato(maria, Vector2(484, 291), Vector2(59, 69))
	elif sala == "peixaria":
		retrato(peixeiro, POS_PEIXEIRO, Vector2(66, 89))
	elif sala == "terreno" and not resgatou:
		# Mingau fica escondido atrás da sucata, longe da entrada.
		retrato(mingau, POS_MINGAU, Vector2(52, 49))
		# O gato fica parcialmente oculto atrás de um caixote.
		draw_rect(Rect2(812, 369, 73, 17), Color("786757"))
		draw_rect(Rect2(805, 363, 86, 7), Color("b69b7b"))
	# A animação indica passos e uma pose diferente ao olhar para cada lado.
	var em_movimento = personagem_fisico.velocity.length() > 0.1
	var balanco = sin(animacao_personagem) * 2.0 if em_movimento else 0.0
	var sprite = garota
	if direcao_olhar.y < -0.45:
		sprite = garota_costas
	elif direcao_olhar.x < -0.45 or direcao_olhar.x > 0.45:
		sprite = garota_lado
	var espelhar = direcao_olhar.x < -0.45
	retrato_personagem(sprite, posicao + Vector2(0, balanco), Vector2(49, 71), espelhar)
	# Portais discretos nas bordas do mapa.
	var destinos: Dictionary = salas[sala]
	if destinos.has("esquerda"):
		draw_rect(Rect2(0, 250, 12, 70), Color("ffcf79"))
	if destinos.has("direita"):
		draw_rect(Rect2(948, 250, 12, 70), Color("ffcf79"))
	if destinos.has("cima"):
		draw_rect(Rect2(390, 94, 180, 12), Color("ffcf79"))
	if destinos.has("baixo"):
		draw_rect(Rect2(390, 468, 180, 11), Color("ffcf79"))
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
	draw_texture_rect(terreno, Rect2(0, 0, 960, 540), false)
	draw_rect(Rect2(0, 266, 960, 274), Color("332834"))
	retrato(mingau, Vector2(480, 142), Vector2(192, 175))
	escrever("MINGAU", 39, 43, 26, COR_SELECAO)
	escrever("Confiança: " + str(confianca) + "/2", 719, 43, 19, COR_VERDE)
	caixa(Rect2(34, 205, 892, 79))
	var linhas = quebrar(mensagem, 86)
	for i in range(mini(linhas.size(), 2)):
		escrever(linhas[i], 57, 243 + 24 * i, 19)
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
