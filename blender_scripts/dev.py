import bpy


def get_collection(collection_name):
    return bpy.data.collections.get(collection_name)


def get_render_active_children_2(value):
    if not value:
        raise ValueError('get_render_active_children_2(null)')

    visible_children = []
    children = value.children

    if children:
        for value_child in children:
            if not value_child.hide_render:
                visible_children.append(value_child)

    return visible_children


print('finding active')
active_children = get_render_active_children_2(get_collection('meshes'))

for child in active_children:
    print(child.name)
