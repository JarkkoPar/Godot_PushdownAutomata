extends Node
class_name stack_machine

# This is the stack machine, which handles the overall game states. 
# It creates the lowest-level states when needed. Each stack_state script
# then can create what ever states they need to create.

var state_stack:Array 		# The state stack
var blackboard:Dictionary	# The blackboard to share data between states


# Called when the node enters the scene tree for the first time.
func _ready():
	initialize()


func initialize() -> void:
	blackboard  = {}
	state_stack = []


# Used to push a new state on to the stack.
func push_state_to_stack( new_state:Node ) -> void:
	new_state.stack_machine = self
	new_state.blackboard = blackboard
	
	
	state_stack.push_back(new_state)
	add_child(new_state)
	new_state.owner = self.owner
	
	new_state.on_state_pushed()


# Used to pop the top-most state off the state stack.
func pop_state_from_stack() -> void:
	if len(state_stack) == 0:
		return
	var popped_state = state_stack.pop_back()
	popped_state.on_state_popped()
	remove_child(popped_state)
	popped_state.queue_free()
	if len(state_stack) > 0:
		state_stack[-1].on_state_reactivated()


# Pops the stack until it is empty.
func clear_stack() -> void:
	while len(state_stack) > 0:
		pop_state_from_stack()


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if len(state_stack) == 0 :
		return
	
	# Run the physics process for all the states in the stack.
	for state in state_stack:
		state.physics_process(delta)
	
	# We tick the top-most stack state.
	state_stack[-1].tick_state(delta)

