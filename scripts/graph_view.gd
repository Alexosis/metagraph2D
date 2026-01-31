extends Node2D

var graph: Graph_Data

@export var run_layout := true

var layout := ForceAtlas2Layout.new()
var running := false

func _draw():
	if graph == null:
		return

	for edge in graph.edges:
		var from_pos = graph.nodes[edge["from"]].pos
		var to_pos = graph.nodes[edge["to"]].pos
		draw_line(from_pos, to_pos, Color.WHITE, 2.0)

@export var graph_node_scene: PackedScene

func build_graph():
	for id in graph.nodes.keys():
		if graph_node_scene == null:
			push_error("GraphNode scene is not assigned!")
			return
		var node = graph_node_scene.instantiate()
		node.node_id = id
		node.position = graph.nodes[id].pos
		node.name = graph.nodes[id].data
		add_child(node)
		node.set_text(graph.nodes[id].data)
		node.moved.connect(func(id, pos):
			graph.nodes[id]["pos"] = pos
			queue_redraw()
			)
	queue_redraw()

func _ready():
	graph = Graph_Data.new()
	
	graph.nodes[0] = { "pos": Vector2(501, 500), "data": "A", "weight": 1.0 }
	graph.nodes[1] = { "pos": Vector2(500, 500), "data": "B", "weight": 2.0 }
	graph.nodes[2] = { "pos": Vector2(500, 501), "data": "C", "weight": 20.0 }
	graph.edges = [
		{"from": 0, "to": 1},
		{"from": 1, "to": 2}
	]
	
	#graph.edges = [
		#[1, 2],
		#[1, 2],
		#[2, 0]
	#]
	layout.reset(graph.nodes)
	running = run_layout
	build_graph()

func _process(delta):
	print('process')
	if not running:
		return
	layout.step(graph.nodes, graph.edges, delta)
	_apply_positions()
	queue_redraw()

func _apply_positions():
	for child in get_children():
		print(child.node_id)
		if child is Graph_Node:
			print("moving node", child.node_id)
			child.global_position = graph.nodes[child.node_id]["pos"]

func start_layout():
	layout.reset(graph.nodes)
	running = true

func stop_layout():
	running = false
