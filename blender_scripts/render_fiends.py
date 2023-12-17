import sys

directory_amulet = 'C:/Users/Jerome/github/amulet'
directory_scripts = f'{directory_amulet}/blender_scripts'
directory_renders = f'{directory_amulet}/resources/renders'
directory_isometric = f'{directory_renders}/isometric'

if directory_scripts not in sys.path:
    sys.path.append(directory_scripts)

from blender_utils import *

name_mesh_kid = 'mesh_kid'
name_material_cell_shade = 'cell_shade'
name_object_rotation = 'rotation'
name_object_direction = 'direction'
name_object_camera = 'camera'
name_object_armature_kid = 'armature_kid'
name_object_render = 'render'
name_collection_exports = 'exports'
name_camera_track_front = 'front'
name_camera_track_isometric = 'isometric'
name_rotation_track_1 = 'rotation_1'
name_rotation_track_8 = 'rotation_8'

direction_north = 'north'
direction_east = 'east'
direction_south = 'south'
direction_west = 'west'
direction_diffuse = 'diffuse'

direction_vector_north = (1, 0.0, 0)
direction_vector_east = (-1, 0.0, 0)
direction_vector_south = (1, 0, 0)
direction_vector_west = (-1, 0, 0)
direction_vector_diffuse = (0, 0, 0)

direction_threshold_north = -0.7
direction_threshold_east = -0.7
direction_threshold_south = -0.4
direction_threshold_west = -0.4
direction_threshold_diffuse = 1


def get_animation_tracks_rig_kid():
    return object_animation_tracks(get_object(name_object_armature_kid))


def get_material_cell_shade():
    return get_material(name_material_cell_shade)


def unmute_rotation_track(pivot_track_name):
    rotation_animation_tracks = object_animation_tracks(get_object(name_object_rotation))
    if rotation_animation_tracks:
        for animation_track in rotation_animation_tracks:
            animation_track.mute = animation_track.name != pivot_track_name


def hide_mesh_kid():
    mesh_obj = try_get_object(name_mesh_kid)
    if mesh_obj:
        set_render_false(mesh_obj)


def get_render_directory_for_camera_track(camera_track):
    return directory_renders + camera_track.name


def get_character_armatures():
    return [armature for armature in scene_armatures() if armature.name.startswith('armature')]


def enable_animation_tracks_by_name(name):
    for armature in get_character_armatures():
        animation_tracks = armature.animation_data.nla_tracks
        for animation_track in animation_tracks:
            animation_track.mute = animation_track.name != name


def render_armature_animation_track(armature, direction, animation_track):
    print(f'render_armature_animation_track({armature.name}, {direction}, {animation_track.name})')
    render_path = f'{directory_isometric}/{armature.name}/{direction}/{animation_track.name}/'
    set_render_path(render_path)
    render()
    render_true(armature)


def render_armature_direction(armature, direction):
    print(f'render_armature_direction({armature.name}, {direction})')
    render_true(armature)
    unmuted_animation_tracks = get_unmuted(object_animation_tracks(armature))

    for animation_track in unmuted_animation_tracks:
        animation_track.mute = True

    for animation_track in unmuted_animation_tracks:
        render_armature_animation_track(armature, direction, animation_track)

    for animation_track in unmuted_animation_tracks:
        animation_track.mute = False


def render_direction(direction):
    print(f'render_direction({direction})')
    set_render_direction(direction)
    exports = get_collection(name_collection_exports)

    if not exports.objects:
        raise ValueError('exports.children not found')

    export_objects_active = []

    for export_object in exports.objects:
        if not export_object.hide_render:
            export_objects_active.append(export_object)

    for render_active_child in export_objects_active:
        render_false(render_active_child)
        render_active_child.hide_set(True)

    for render_active_child in export_objects_active:
        if object_is_type_armature(render_active_child):
            render_armature_direction(render_active_child, direction)

    for render_active_child in export_objects_active:
        render_true(render_active_child)
        render_active_child.hide_set(False)


def map_direction_to_vector(direction):
    if direction == direction_north:
        return direction_vector_north
    if direction == direction_east:
        return direction_vector_east
    if direction == direction_south:
        return direction_vector_south
    if direction == direction_west:
        return direction_vector_west
    if direction == direction_diffuse:
        return direction_vector_diffuse
    raise ValueError('invalid direction')


def map_direction_to_threshold(direction):
    if direction == direction_north:
        return direction_threshold_north
    if direction == direction_east:
        return direction_threshold_east
    if direction == direction_south:
        return direction_threshold_south
    if direction == direction_west:
        return direction_threshold_west
    if direction == direction_diffuse:
        return direction_threshold_diffuse
    raise ValueError('invalid direction')


def set_render_direction(direction):
    material = get_material_cell_shade()
    nodes = material.node_tree.nodes

    for node in nodes:
        if node.type == 'VECT_MATH':
            node.inputs[1].default_value = map_direction_to_vector(direction)
            continue

        if node.type == 'MATH':
            node.inputs[1].default_value = map_direction_to_threshold(direction)
            continue


def render_fiends():
    print('render_fiends()')
    set_render_engine_eevee()
    set_render_frames(1, 64)
    active_direction_tracks = object_animation_tracks_active(get_object(name_object_direction))

    for active_direction_track in active_direction_tracks:
        render_direction(active_direction_track.name)


render_fiends()
set_render_path("c:/tmp/")
print('render fiends complete')
