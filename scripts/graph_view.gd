extends Node2D

var graph: Graph_Data

@onready var detail_panel: NodeDetail = $CanvasLayer/NodeDetail

func _draw():
	if graph == null:
		return

	for edge in graph.edges:
		var from_pos = graph.nodes[edge[0]].pos
		var to_pos = graph.nodes[edge[1]].pos
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
		node.name = graph.nodes[id].NodeName
		add_child(node)
		node.set_text(graph.nodes[id].NodeName)
		node.moved.connect(func(id, pos):
			graph.nodes[id]["pos"] = pos
			queue_redraw()
			)
		node.clicked.connect(func(id, _screen_pos):
			var data: Dictionary = graph.nodes[id]
			detail_panel.show_data(data)
			)
	queue_redraw()

func _ready():
	graph = Graph_Data.new()
	
	graph.nodes[1] = { "pos": Vector2(200, 200), "NodeName": "A", "type": "Pers", "description": "Aaaa"}
	graph.nodes[2] = { "pos": Vector2(400, 300), "NodeName": "B", "type": "Pers", "description": "Aaaa"}
	graph.nodes[3] = { "pos": Vector2(300, 100), "NodeName": "C", "type": "Pers", "description": "Aaaa"}
	graph.edges = [
		[1, 2],
		[2, 3],
		[3, 1]
	]
	build_graph()
