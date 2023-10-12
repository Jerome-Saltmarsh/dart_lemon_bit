import bpy

# Specify the name of your material and the node to change
material_name = "cell_shade"
node_name_to_change = "Greater Than"

# Get the material
material = bpy.data.materials.get(material_name)

# Check if the material exists
if material is not None:
    # Access the material's node tree
    node_tree = material.node_tree

    # Iterate through all the nodes in the node tree
    for node in node_tree.nodes:
        # Check if the node is the one you want to change
        if node.type == 'MATH' and node.operation == 'GREATER_THAN':
            # Change the operation to Less Than
            node.operation = 'LESS_THAN'
            node.name = node_name_to_change  # Optional: Change the node's name

        if node.type == 'MATH' and node.operation == 'LESS_THAN':
            # Change the operation to Less Than
            node.operation = 'GREATER_THAN'
            node.name = node_name_to_change  # Optional: Change the node's name

    # Update the material to reflect the changes
#    material.update()

    # Save the changes
#    bpy.data.materials.update()

else:
    print("Material '{}' not found.".format(material_name))
