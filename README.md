# Godot_StackMachine
A GDScript implementation of a Stack Machine: a stack-based state machine.

## Installation

Just copy these to your project, and they will be available as nodes and in GDScript.


## What is a stack machine?

A stack machine is a state machine that instead of connecting various states to one another, handles state changes by stacking them on top of one another. The top-most state in the stack is the active one. 

This is **very** convinient for games where the states need to go back and forth between different state hierarchies rather than transitioning between them in a more random manner.

The states can share variables and have local variables to allow for communication between the states. This implementation of the stack machine uses a *blackboard* for sharing variables.


## How does it work?

You add the `stack_machine` node in your scene. Then you create the states you need (see section below on how to do that) and push them on to the stack. 

This implementation of the stack machine works dynamically, which means that the states are created when they are added to the stack, and deleted when they are popped off form the stack.

Let's assume you are creating a turn based game like XCOM: Enemy Unknown. When the player's turn starts, you push the default state on the stack. The default state handles mouse input and camera controls, and clicking on the units on the map.

When the player clicks their unit, the default state adds the selected unit to the blackboard as a variable and pushes the unit_selected state on the stack. Now the unit_selected state handles what happens when a tile or a unit is clicked. The default state continues to handle camera controls and mouse movement.

When the player clicks an empty tile, the unit_selected state pushes the move_unit state on the stack which now becomes the active state. The move_unit state disables mouse click handling and moves the selected unit to the clicked location. When the unit arrives to the target location, the move_unit state pops itself out of the stack. 

The unit_selected state is now reactivated and it again starts handling clicking units on the map.

When the player presses the ESC-key, the unit_selected state pushes the in_game_menu state on top of the stack, which then handles the input. And so on.


## How do I create states?

You extend the stackable_state.gd class with your custom content. The stackable_state has the following methods that you can override:

```gdscript

# This is called when the stack has been initialized and added
# to the stack.
func on_state_pushed() -> void:
	pass


# This is called when the stack has just been popped from the
# stack, but before it is deleted with queue_free().
func on_state_popped() -> void:
	pass


# This is called when the state on top of this state has just
# been popped.
func on_state_reactivated() -> void:
	pass


# This is called only for the top-most state in the stack each
# physics frame.
func tick_state(delta) -> void:
	pass


# This is ticked every physics frame, going from the state
# at the bottom of the stack towards the one on top.
func physics_process(delta) -> void:
	pass

```

**Note !** Currently the `stack_machine` class calls the `physics_process(delta)` for the stacked states and `tick_state(delta)` for the top-most state in its `_physics_process(delta)` method. If you want more control over when these are called, just change the name of the `stack_machine`'s `_physics_process(delta)` method and call it where you want to in your code.


## How do I push and pop the states? 

In your script, load them first: `@onready var my_custom_state_template = preload("res://my_custom_state.gd")`. 

Then in your code you just instantiate the state when you need to push it to the stack. To add the first state, you need to use the `stack_machine` node:
```gdscript
$stack_machine.push_state_to_stack(my_custom_state_template.new())
```

And within each state, you can push them like this:
```gdscript
push_state_to_stack(my_custom_state.new())
```

To pop a state you just call the `pop_state_from_stack()` method similarly to how you call the push method. Often times a state will call `pop_state_from_stack()` to pop itself out of the stack when it is done.

## How do I use the blackboard?

The blackboard is a property in the `stack_machine` node, so outside of the stackable states you need to use `stack_machine.blackboard["key"] = value` syntax. Within a stackable state you just need to call `blackboard["other_key"] = other_value`.


