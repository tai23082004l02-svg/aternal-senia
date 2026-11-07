class_name SwipeScroll
extends ScrollContainer
## Let native ScrollContainer receive drags that start over cards and buttons.
## Godot cancels descendant button presses at SCROLL_BEGIN and handles inertia.

var prepare_queued := false

func _ready() -> void:
	scroll_deadzone = 12
	get_tree().node_added.connect(_node_added)
	_prepare_content()

func _node_added(node: Node) -> void:
	if not prepare_queued and is_ancestor_of(node):
		prepare_queued = true
		_prepare_content.call_deferred()

func _prepare_content() -> void:
	prepare_queued = false
	_prepare_branch(self)

func _prepare_branch(parent: Node) -> void:
	for child in parent.get_children():
		# Nested scrollers own their gestures. Keep text/range controls and
		# interactive portraits in charge of their own drag gestures.
		if child is ScrollContainer or child is Range or child is LineEdit or child is TextEdit or child is HeroPortrait:
			continue
		if child is Control and child.mouse_filter == Control.MOUSE_FILTER_STOP:
			child.mouse_filter = Control.MOUSE_FILTER_PASS
		_prepare_branch(child)
