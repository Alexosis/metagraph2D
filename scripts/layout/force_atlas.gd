extends RefCounted
class_name ForceAtlasLayout

var repulsion_strength := 2000000.0
var attraction_strength := 0.01
var damping := 0.85
var max_speed := 500.0

var velocities := {} # id -> Vector2

func reset(nodes: Dictionary):
	velocities.clear()
	for id in nodes.keys():
		velocities[id] = Vector2.ZERO

func step(nodes: Dictionary, edges: Array, delta: float) -> Dictionary:
	# --- REPULSION ---
	for id_a in nodes.keys():
		var pos_a: Vector2 = nodes[id_a]["pos"]
		
		for id_b in nodes.keys():
			if id_a == id_b:
				continue
				
			var pos_b: Vector2 = nodes[id_b]["pos"]
			var dir := pos_a - pos_b
			var dist : int = max(dir.length(), 1.0)
			var force : int = repulsion_strength / (dist * dist)
			
			velocities[id_a] += dir.normalized() * force * delta
			#print(velocities[id_a])
	
	# --- ATTRACTION ---
	for edge in edges:
		var a : int = edge[0]
		var b : int = edge[1]
		
		var pos_a: Vector2 = nodes[a]["pos"]
		var pos_b: Vector2 = nodes[b]["pos"]
		
		var dir := pos_b - pos_a
		var dist := dir.length()
		var force := dist * attraction_strength
		velocities[a] += dir.normalized() * force * delta
		velocities[b] -= dir.normalized() * force * delta
		
	# --- INTEGRATION ---
	for id in nodes.keys():
		velocities[id] *= damping
		velocities[id] = velocities[id].limit_length(max_speed)
		nodes[id]["pos"] += velocities[id] * delta

	return nodes
