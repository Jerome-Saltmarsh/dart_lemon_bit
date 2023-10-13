import bpy


def assign_method_west():
    assign_method('LESS_THAN')


def assign_method_south():
    assign_method('GREATER_THAN')


def assign_method(operation):
    material = bpy.data.materials.get("cell_shade")

    if material is None:
        raise ValueError('failed to set material property')

    nodes = material.node_tree.nodes

    for node in nodes:
        if not node.type == 'MATH':
            continue

        if node.operation == operation:
            return

        if node.operation == 'GREATER_THAN' or node.operation == 'LESS_THAN':
            node.operation = operation
            return

    raise ValueError('could not find math node')
