class_name ComponentUtil

static func get_one_child_of_type(root: Node, type: Variant) -> Node:
	var out: Node = null
	for child in root.get_children():
		if is_instance_of(child, type):
			if out:
				push_warning("Duplicate ", type, " child of ", root, " ignoring it and using ", out)
			out = child
	if not out:
		push_error("Node ", root, " has no child of type ", type)
	return out
