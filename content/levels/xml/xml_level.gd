extends Node2D

@export var level_file: String

@onready var bg_color: ColorRect = $CanvasLayer/BgColor
@onready var bg_picture: Sprite2D = $Parallax/BgPicture
@onready var tiles: TileMapLayer = $Tiles
@onready var stickers: TileMapLayer = $Stickers
@onready var coins: TileMapLayer = $Coins
@onready var potions: TileMapLayer = $Potions
@onready var weapons: TileMapLayer = $Weapons

@onready var player: Player = $Player

var tile_set_outside = preload("res://content/levels/tile_set.tres") as TileSet
var tile_set_inside = preload("res://content/levels/tile_set_inside.tres") as TileSet
var tile_set_lav = preload("res://content/levels/tile_set_lav.tres") as TileSet
const tile_set_net = preload("res://content/levels/tile_set_net.tres") as TileSet

var bitter = preload("res://content/characters/bitter.tscn") as PackedScene
var goblin = preload("res://content/characters/goblin.tscn") as PackedScene
var boss = preload("res://content/characters/boss.tscn") as PackedScene

const trader = preload("res://content/characters/trader.tscn") as PackedScene
const talker = preload("res://content/characters/talker.tscn") as PackedScene

const change_map_helper = preload("res://content/helpers/change_map_helper.tscn") as PackedScene
const kill_the_human_helper = preload("res://content/helpers/kill_the_human_helper.tscn") as PackedScene
const talker_helper = preload("res://content/helpers/talker_helper.tscn") as PackedScene
const trader_helper = preload("res://content/helpers/trader_helper.tscn") as PackedScene


func _ready() -> void:
	GameManager.go_to_game()
	var parser = XMLParser.new()
	parser.open("res://content/levels/xml/" + level_file)
	var current_section = ""
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			if node_name in ["items", "characters", "tiles", "stickers", "helpers"]:
				current_section = node_name
				continue
			var attributes_dict = {}
			for idx in range(parser.get_attribute_count()):
				attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)

			if node_name == "level":
				var color = "#%06X" % int(attributes_dict.bgcolor)
				bg_color.color = Color("#%06X" % int(attributes_dict.bgcolor))

				if attributes_dict.has("bgpicture") and attributes_dict.bgpicture == "graphics/clouds2.png":
					bg_picture.texture = load("res://content/graphics/clouds2.png")
					bg_picture.visible = true
				elif attributes_dict.has("bgpicture") and attributes_dict.bgpicture == "graphics/MonsterKnifeBG.jpg":
					bg_picture.texture = load("res://content/graphics/MonsterKnifeBG.jpg")
					bg_picture.visible = true
				else:
					bg_picture.visible = true

				if attributes_dict.name == "LAV":
					tiles.tile_set = tile_set_lav
				elif attributes_dict.name == "FUNGUS":
					tiles.tile_set = tile_set_outside
				elif attributes_dict.name == "tower" or attributes_dict.name == "home":
					tiles.tile_set = tile_set_inside
				elif attributes_dict.name == "net" or attributes_dict.name == "net2":
					tiles.tile_set = tile_set_net
				else:
					tiles.tile_set = tile_set_outside
			elif current_section == "characters" and attributes_dict.type == "player":
				var x = int(attributes_dict.x)
				var y = int(attributes_dict.y)
				player.global_position = xml_to_global_coords_helper(x, y)
			elif current_section == "characters" and attributes_dict.type == "enemy" and attributes_dict.enemyType == "0":
				var bitter = bitter.instantiate() as CharacterBody2D
				var x = int(attributes_dict.x)
				var y = int(attributes_dict.y)
				bitter.global_position = xml_to_global_coords(x, y)
				add_child(bitter)
			elif current_section == "characters" and attributes_dict.type == "enemy" and attributes_dict.enemyType == "1":
				var goblin = goblin.instantiate() as CharacterBody2D
				var x = int(attributes_dict.x)
				var y = int(attributes_dict.y)
				goblin.global_position = xml_to_global_coords(x, y)
				add_child(goblin)
			elif current_section == "characters" and attributes_dict.type == "boss":
				var boss = boss.instantiate() as CharacterBody2D
				var x = int(attributes_dict.x)
				var y = int(attributes_dict.y)
				boss.global_position = xml_to_global_coords(x, y)
				add_child(boss)
			elif current_section == "characters" and attributes_dict.type == "trader":
				var trader = trader.instantiate() as Area2D
				var x = int(attributes_dict.x)
				var y = int(attributes_dict.y)
				var coords = xml_to_global_coords_helper(x, y)
				trader.global_position = coords
				add_child(trader)

				var helper = trader_helper.instantiate() as Area2D
				helper.trade_data = load("res://content/dialogs/trade_data_trader.tres")
				helper.global_position = coords
				add_child(helper)
			elif current_section == "characters" and attributes_dict.type == "talker":
				var talker = talker.instantiate() as StaticBody2D
				var x = int(attributes_dict.x)
				var y = int(attributes_dict.y)
				var coords = xml_to_global_coords_helper(x, y)
				talker.global_position = coords
				add_child(talker)

				var helper = talker_helper.instantiate() as Area2D
				helper.talk_data = load("res://content/dialogs/talk_data_madguy.tres")
				helper.global_position = coords
				add_child(helper)
			elif current_section == "tiles" and node_name == "element":
				var id = int(attributes_dict.id)
				var atlas_coords = Vector2i(id % 10, id / 10)
				var isSolid = attributes_dict.solid == "true"
				#tiles.tile_set.phys
				tiles.tile_set.add_physics_layer()

				tiles.set_cell(
					Vector2i(int(attributes_dict.x), int(attributes_dict.y)),
					2,
					atlas_coords,
				)
			elif current_section == "stickers" and node_name == "element":
				var id = int(attributes_dict.id)
				var atlas_coords = Vector2i(id % 10, id / 10)
				stickers.set_cell(
					Vector2i(int(attributes_dict.x), int(attributes_dict.y)),
					1,
					atlas_coords,
				)
			elif current_section == "items" and node_name == "element":
				if attributes_dict.type == "coin":
					var scene_id = 0
					if attributes_dict.coinAmount == "1":
						scene_id = 1
					elif attributes_dict.coinAmount == "5":
						scene_id = 4
					elif attributes_dict.coinAmount == "25":
						scene_id = 5
					else:
						scene_id = 1
					coins.set_cell(
						Vector2i(int(attributes_dict.x), int(attributes_dict.y)),
						0,
						Vector2i(0, 0),
						scene_id
					)
				elif attributes_dict.type == "potion":
					var scene_id = 0
					if attributes_dict.potionAmount == "25":
						scene_id = 1
					elif attributes_dict.potionAmount == "50":
						scene_id = 2
					elif attributes_dict.potionAmount == "100":
						scene_id = 3
					else:
						scene_id = 1
					potions.set_cell(
						Vector2i(int(attributes_dict.x), int(attributes_dict.y)),
						0,
						Vector2i(0, 0),
						scene_id
					)
				elif attributes_dict.type == "weapon":
					var scene_id = 0
					if attributes_dict.weaponDamage == "10":
						scene_id = 1
					elif attributes_dict.weaponDamage == "100":
						scene_id = 2
					else:
						scene_id = 1
					weapons.set_cell(
						Vector2i(int(attributes_dict.x), int(attributes_dict.y)),
						0,
						Vector2i(0, 0),
						scene_id
					)
					pass
			elif current_section == "helpers" and node_name == "element":
				if attributes_dict.name == "SpawnPoint":
					var x = int(attributes_dict.x)
					var y = int(attributes_dict.y)
					player.global_position = xml_to_global_coords_helper(x, y)
				elif attributes_dict.type == "nextlevel":
					var helper = change_map_helper.instantiate() as Area2D
					var x = int(attributes_dict.x)
					var y = int(attributes_dict.y)
					helper.global_position = xml_to_global_coords_helper(x, y)
					add_child(helper)
				elif attributes_dict.type == "killer":
					var helper = kill_the_human_helper.instantiate() as Area2D
					var x = int(attributes_dict.x)
					var y = int(attributes_dict.y)
					helper.global_position = xml_to_global_coords_helper(x, y)
					add_child(helper)


func xml_to_global_coords(x: int, y: int) -> Vector2:
	return Vector2((x + 9) * 40.0, (y + 7) * 40)


func xml_to_global_coords_helper(x: int, y: int) -> Vector2:
	return Vector2((x + 9) * 40.0 + 20, (y + 9) * 40)
