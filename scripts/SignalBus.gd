extends Node


# --- global signals --- #
signal next_turn
signal attributes_changed(object)                     # emitted when ships change attributes
# ship signals
signal obj_selected(new_selected, old_selected)       # emitted when ships are selected
signal obj_deselected(old_selected)                   # emitted when ships are deselected
signal damaged(obj_damaged, num_damaged : int)        # emitted when a ship is damaged
signal turn_complete(ship)                            # emitted when a ship is done with its turn
signal ship_destroyed(ship)                           # emitted when a ship is destroyed
# weapon signals
signal obj_hit(obj, weapon, damage : int, origin)     # emitted when a weapon hits an object
signal shell_destroyed(weapon, origin)                # emitted when a shell calls queue_free()
# ui signals
signal ui_torpedo
signal ui_railgun
signal ui_pdc
signal ui_boarding
# --- global signals --- #
