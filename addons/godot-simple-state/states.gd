extends Node

onready var _Parent = get_parent()

var allowed: Dictionary = {}
export(String) var current: String = ""

var states = {}


func _ready():
	self.setup()


func setup():
	"""
	Removes all child states and saves them to our state map
	We will then mount the current state so it can still receive
	the godot input methods such as _physics_process
	"""
	for child in self.get_children():
		states[child.name] = child

		if "States" in child:
			child.States = self

		if "Parent" in child:
			child.Parent = _Parent

		if child.name != current:
			self.remove_child(child)

	self.call("_state_enter")


func goto(state: String, args = null):
	"""
	Changes to another state
	If a state is loaded it will first call "_state_exit"
	The loaded state will enter with "_state_enter"
	"""
	if not state in states:
		push_error("Could not find state %s in state list" % state)
		return
	
	self.call("_state_exit")

	if len(current):
		self.remove_child(states[current])

	self.current = state
	self.add_child(states[current])
	
	self.call("_state_enter", args)


func call(method: String, args = null):
	"""
	Call a method on the current state with arguments
	Accepts:
	 - Single argument
	 - Array argument (spread over function)
	 - No argument
	"""
	if not len(current) or not current in states:
		return

	if not states[current].has_method(method): 
		return
	
	if args != null:
		return states[current].call(method, args)
	
	else:
		return states[current].call(method)

func _call(args, method: String):
	"""
	Inbound hook for attaching signals
	Bind the custom method name
	"""
	return self.call(method, args)
