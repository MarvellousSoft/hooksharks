extends Node2D

onready var initial_position = position

const MEGAHOOK_SPRITE = preload("res://assets/images/elements/megahook.png")

const infinite_dive = preload("res://gameplay/objects/powerups/InfiniteDive.tscn")
const megahook = preload("res://gameplay/objects/powerups/MegaHook.tscn")
const trail_power = preload("res://gameplay/objects/powerups/TrailPower.tscn")

const oxygen_barrel = preload("res://assets/images/powerup/barrelo2.png")
const wooden_barrel = preload("res://assets/images/powerup/barrelo3.png")
const metal_barrel = preload("res://assets/images/powerup/Barrel3.png")

const ob_shader = preload("res://assets/images/powerup/barrelo2_o.png")
const wb_shader = preload("res://assets/images/powerup/barrel2_o.png")
const mb_shader = preload("res://assets/images/powerup/Barrel3_o.png")

const wooden_particle = preload("res://assets/images/powerup/barril_quebrando_particula.png")
const metal_particle = preload("res://assets/images/powerup/metalbarrel_particle.png")


const POWERS = [infinite_dive,
				megahook,
                trail_power]
				
const CRATES = [oxygen_barrel,
				wooden_barrel,
                metal_barrel]

const SHADERS = [ob_shader,
				 wb_shader,
                 mb_shader]
				
const PARTICLES = [wooden_particle,
				   wooden_particle,
                   metal_particle]

export(PackedScene) var powerup

var current_index = 0
var random = false
var hook


func _ready():
	randomize()
	$Hitbox.disconnect("area_entered", self, "_on_Hitbox_area_entered")
	if not powerup:
		random = true
		set_random_power()
	else:
		for i in POWERS.size():
			if powerup.resource_path == POWERS[i].resource_path:
				current_index = i
		
		$Sprite.set_texture(CRATES[current_index])
		$Sprite2.set_texture(SHADERS[current_index])
		$Particles2D.set_texture(PARTICLES[current_index])


func _physics_process(delta):
	if hook:
		position = hook.position


func set_hook(new_hook):
	if hook:
		hook.retract()
	hook = new_hook


func remove_hook():
	hook = null


func despawn():
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	$Sprite2.set_modulate(Color(1, 1, 1, 0))
	$Sprite2/AnimationPlayer.stop()
	$Sprite.set_modulate(Color(1, 1, 1, 0))
	$Sprite/AnimationPlayer.stop()
	$Particles2D.emitting = true
	$Sprite.hide()
	$Sprite2.hide()
	


func spawn():
	if random:
		set_random_power()
	$Sprite.set_texture(CRATES[current_index])
	$Sprite2.set_texture(SHADERS[current_index])
	$Particles2D.set_texture(PARTICLES[current_index])
	position = initial_position
	$Hitbox/CollisionShape2D.set_deferred("disabled", false)
	$Sprite2/AnimationPlayer.play("spawn")
	$Sprite/AnimationPlayer.play("spawn")
	$Sprite.show()
	$Sprite2.show()
	


func activate(player):
	var power = powerup.instance()
	# If initialized sucessfully, add it to player
	if power.init(player):
		player.get_node("PowerUps").call_deferred("add_child", power)
#		player.get_node("PowerUps").add_child(power)
		player.add_label(power.power_name)
		if powerup == megahook:
			player.riders_hook.texture = MEGAHOOK_SPRITE
	if hook:
		hook.free_hook()
	
	despawn()
	$RespawnTimer.start()


func set_random_power():
	current_index = randi() % POWERS.size()
	powerup = POWERS[current_index]