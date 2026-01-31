extends RefCounted
class_name ForcePlanetaryLayout

var repulsion_strength := 20.0
var hubbles_constant := 20
var edge_weight_multiplier := 2.0
var attraction_strength := 10
var damping := 0.85
var max_speed := 200.0

var velocities := {} # id -> Vector2

func _calculate_avg_mass(nodes: Dictionary) -> int:
	var sum = 0.0
	for node in nodes.keys():
		sum += nodes[node]["weight"]
	if nodes.size() > 0:
		return sum / nodes.size()
	else:
		return 0.0

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
	var avg_speed := _calculate_avg_mass(nodes)
	
	# --- REPULSION ---
	for id_a in nodes.keys():
		var pos_a: Vector2 = nodes[id_a]["pos"]
		var speed_a: int = hubbles_constant / nodes[id_a]["weight"]
		
		for id_b in nodes.keys():
			if id_a == id_b:
				continue
			var speed_b: int = hubbles_constant / nodes[id_b]["weight"]
			var pos_b: Vector2 = nodes[id_b]["pos"]
			var dir := pos_a - pos_b
			var dist : int = max(dir.length(), 1.0)
			var force : float = repulsion_strength * nodes[id_b]["weight"] * ((abs(speed_a - speed_b) + hubbles_constant / avg_speed) * (abs(speed_a - speed_b) + hubbles_constant / avg_speed)) / dist
			
			velocities[id_a] += dir.normalized() * force * delta
			#print(velocities[id_a])
	
	# --- ATTRACTION ---
	for a in edge_map.keys():
		var pos_a: Vector2 = nodes[a]["pos"]
		
		for link in edge_map[a]:
			var b: int = link["to"]
			var weight: float = link["weight"]
			
			var mutual_weigth = nodes[a]["weight"] * link["weight"]
			
			var pos_b: Vector2 = nodes[b]["pos"]
			
			var dir := pos_b - pos_a
			var dist : float = max(dir.length(), 1.0)
			var force : float = attraction_strength * mutual_weigth * edge_weight_multiplier / (dist * dist)
			velocities[a] += dir.normalized() * force * delta 
		
	# --- INTEGRATION ---
	for id in nodes.keys():
		velocities[id] *= damping
		velocities[id] = velocities[id].limit_length(max_speed)
		nodes[id]["pos"] += velocities[id] * delta

	return nodes
