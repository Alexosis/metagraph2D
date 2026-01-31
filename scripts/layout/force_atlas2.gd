extends RefCounted
class_name ForceAtlas2Layout

var repulsion_strength := 100000000.0
var edge_weight_multiplier := 2.0
var attraction_strength := 0.01
var damping := 0.85
var max_speed := 500.0

var velocities := {} # id -> Vector2

func _build_edge_manp(edges: Array, nodes: Dictionary) -> Dictionary:
	var map:= {}
	for edge in edges:
		var a: int = edge["from"]
		var b: int = edge["to"]
		var w: float = nodes[edge["from"]]["weight"] * nodes[edge["to"]]["weight"]
		
		map[a] = map.get(a, [])
		map[a].append({ "to": b, "weight": w })
		
		map[b] = map.get(b, [])
		map[b].append({"to": a, "weight": w})
	return map

func reset(nodes: Dictionary):
	velocities.clear()
	for id in nodes.keys():
		velocities[id] = Vector2.ZERO

func step(nodes: Dictionary, edges: Array, delta: float) -> Dictionary:
	
	var edge_map := _build_edge_manp(edges, nodes)
	
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
	for a in edge_map.keys():
		var pos_a: Vector2 = nodes[a]["pos"]
		
		for link in edge_map[a]:
			var b: int = link["to"]
			var weight: float = link["weight"]
			
			var pos_b: Vector2 = nodes[b]["pos"]
			
			var dir := pos_b - pos_a
			var dist : float = max(dir.length(), 1.0)
			var force : float = dist * attraction_strength * weight * edge_weight_multiplier
			velocities[a] += dir.normalized() * force * delta 
		
	# --- INTEGRATION ---
	for id in nodes.keys():
		velocities[id] *= damping
		velocities[id] = velocities[id].limit_length(max_speed)
		nodes[id]["pos"] += velocities[id] * delta

	return nodes
