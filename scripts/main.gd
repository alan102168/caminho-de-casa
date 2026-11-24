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
var maria: Texture2D = preload("res://assets/maria.svg")
var peixeiro: Texture2D = preload("res://assets/peixeiro.svg")
var mingau: Texture2D = preload("res://assets/mingau.svg")
var filhotes: Texture2D = preload("res://assets/filhotes.svg")

# Cada cena é uma área separada. Use as saídas nas bordas para viajar.
var sala = "rua"
var posicao = Vector2(480, 392)
var direcao_olhar = Vector2(0, 1)
var passos = 0.0
const POS_MARIA = Vector2(490, 290)
const POS_PEIXEIRO = Vector2(479, 314)
const POS_MINGAU = Vector2(760, 175)
var salas: Dictionary = {
	"rua": {"nome": "Rua das Acácias", "esquerda": "praca", "direita": "viela", "cima": "peixaria"},
	"praca": {"nome": "Praça da Figueira", "direita": "rua", "cima": "casa"},
	"casa": {"nome": "Casa da Dona Maria", "baixo": "praca"},
	"peixaria": {"nome": "Peixaria do Zé", "baixo": "rua"},
	"viela": {"nome": "Viela do Campinho", "esquerda": "rua", "direita": "terreno"},
	"terreno": {"nome": "Terreno baldio", "esquerda": "viela"}
}
var fotos: Dictionary = {
	"rua": preload("res://assets/maps/rua.svg"),
	"praca": preload("res://assets/maps/praca.svg"),
	"casa": preload("res://assets/maps/casa.svg"),
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
	queue_redraw()

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
	if modo == "mundo" and not caderno:
		var d = eixo()
		if d != Vector2.ZERO:
			direcao_olhar = d
			passos += delta * 9.0
		posicao += d * 192.0 * delta
		transicao_portas()
		posicao.x = clampf(posicao.x, 36.0, 924.0)
		posicao.y = clampf(posicao.y, 111.0, 464.0)
	elif modo == "batalha" and fase == "esquiva":
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
		posicao = Vector2(894, posicao.y)
		aviso = "Você entrou em " + salas[sala]["nome"] + "."
	elif posicao.x > 923.0 and destinos.has("direita"):
		sala = destinos["direita"]
		posicao = Vector2(65, posicao.y)
		aviso = "Você entrou em " + salas[sala]["nome"] + "."
	elif posicao.y < 112.0 and destinos.has("cima") and posicao.x > 340 and posicao.x < 620:
		sala = destinos["cima"]
		posicao = Vector2(480, 426)
		aviso = "Você entrou em " + salas[sala]["nome"] + "."
	elif posicao.y > 463.0 and destinos.has("baixo") and posicao.x > 340 and posicao.x < 620:
		sala = destinos["baixo"]
		posicao = Vector2(480, 141)
		aviso = "Você entrou em " + salas[sala]["nome"] + "."

func interagir() -> void:
	if sala == "casa" and posicao.distance_to(POS_MARIA) < 100.0:
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
		return "Objetivo: encontre Dona Maria na casa acima da praça."
	if peixe or peixe_dado:
		return "Objetivo: procure Mingau no terreno depois da viela."
	return "Objetivo: procure a peixaria na parte alta da rua."

func desenhar_mundo() -> void:
	draw_texture_rect(fotos[sala], Rect2(0, 0, 960, 540), false)
	if sala == "casa":
		retrato(maria, POS_MARIA, Vector2(69, 92))
	elif sala == "peixaria":
		retrato(peixeiro, POS_PEIXEIRO, Vector2(66, 89))
	elif sala == "terreno" and not resgatou:
		# Mingau fica escondido atrás da sucata, longe da entrada.
		retrato(mingau, POS_MINGAU, Vector2(120, 90))
		draw_rect(Rect2(742, 213, 101, 34), Color("7b675b"))
		draw_rect(Rect2(737, 209, 114, 8), Color("ae9381"))
	# A protagonista tem 4 direções e uma animação simples de caminhada.
	var balanco = sin(passos * 2.8) * 3.0 if eixo() != Vector2.ZERO else 0.0
	retrato(garota, posicao + Vector2(0, balanco), Vector2(55, 82))
	var sombra = Rect2(posicao.x - 23, posicao.y + 34, 46, 7)
	draw_rect(sombra, Color(0, 0, 0, 0.20))
	# A seta aponta para a direção para onde a menina está olhando.
	var inicio = posicao + Vector2(0, -50)
	draw_line(inicio, inicio + direcao_olhar * 15.0, COR_SELECAO, 3)
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
	retrato(mingau, Vector2(480, 143), Vector2(151, 114))
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
