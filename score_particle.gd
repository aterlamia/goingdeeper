extends CPUParticles2D

var tileWidth: int = 64
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_tile(tile: Tile) -> void:
	lifetime = 1.0
	speed_scale = 2.0

	var atlas_texture = AtlasTexture.new()
	
	atlas_texture.atlas = load("res://tiles.png")
	var texture_coord = tile.getTextureCoord()
	var atlas_offset = texture_coord * tileWidth
	atlas_texture.region = Rect2(atlas_offset.x, atlas_offset.y, 64, 64)
	# Set the region for the particle
	texture = atlas_texture
