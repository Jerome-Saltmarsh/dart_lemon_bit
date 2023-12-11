import bpy
import os
import subprocess

object_type_armature = 'ARMATURE'
render_engine_eevee = 'BLENDER_EEVEE'

print('current_dir: ' + os.path.dirname(bpy.data.filepath))


def get_material(name):
    material = bpy.data.materials.get(name)
    if material is None:
        raise ValueError(f'get_material({name}) - not found')
    return material


def object_animation_tracks(obj):
    if not obj:
        raise ValueError(f'get_animation_tracks({obj})')

    animation_data = obj.animation_data

    if not animation_data:
        raise ValueError(f'get_animation_tracks({obj}) animation_data is null')

    nla_tracks = animation_data.nla_tracks

    if not nla_tracks:
        raise ValueError(f'get_animation_tracks({obj}) nla_tracks is null')

    return nla_tracks


def object_animation_tracks_active(obj):
    unmuted_tracks = []
    animation_tracks = object_animation_tracks(obj)
    for animation_track in animation_tracks:
        if not animation_track.mute:
            unmuted_tracks.append(animation_track)

    return unmuted_tracks


def get_render_active_children(children):
    visible_children = []
    if children:
        for child_collection in children.children:
            if not child_collection.hide_render:
                visible_children.append(child_collection)

    return visible_children


def set_render_engine(value):
    bpy.context.scene.render.engine = value


def set_render_engine_eevee():
    set_render_engine(render_engine_eevee)


def set_render_false(target):
    target.hide_render = True
    target_children = target.children
    if target_children:
        for target_child in target_children:
            set_render_false(target_child)


def set_render(target, value):
    target.hide_render = not value
    target_children = target.children
    if target_children:
        for target_child in target_children:
            set_render(target_child, value)


def render_true(target):
    set_render(target, True)


def render_false(target):
    set_render(target, False)


def get_object(object_name):
    value = try_get_object(object_name)
    if not value:
        raise ValueError(f'get_object({object_name}) - no object found')
    return value


def try_get_object(object_name):
    return bpy.data.objects.get(object_name)


def get_collection(collection_name):
    collection = bpy.data.collections.get(collection_name)
    if not collection:
        raise ValueError(f'get_collection{collection_name} could not be found')
    return collection


def render():
    bpy.ops.render.render(animation=True)


def set_render_path(value):
    bpy.context.scene.render.filepath = value


def scene_armatures():
    return find_objects_by_type(object_type_armature)


def find_objects_by_type(object_type):
    return [obj for obj in bpy.context.scene.objects if obj.type == object_type]


def get_armatures_render_enabled():
    return [armature for armature in scene_armatures() if not armature.hide_render]


def set_animation_track_muted(object_name, track_name, value):
    animation_tracks = object_animation_tracks(get_object(object_name))
    if animation_tracks:
        for animation_track in animation_tracks:
            if animation_track.name == track_name:
                animation_track.mute = value
                return


def set_render_frames(start, end):
    scene = bpy.context.scene
    scene.frame_start = start
    scene.frame_end = end


def mute_animation_tracks(object_name):
    animation_tracks = object_animation_tracks(get_object(object_name))
    if animation_tracks:
        for animation_track in animation_tracks:
            animation_track.mute = True


# BUSINESS LOGIC

directory_renders = 'C:/Users/Jerome/github/amulet/resources/renders/'

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


def build_sprites_from_renders():
    print('build_sprites_from_renders()')
    program_path = r'C:\Users\Jerome\github\amulet\lemon_atlas\build\windows\runner\Release\lemon_sprites.exe'
    program_args = ['sync_all']
    try:
        subprocess.run([program_path] + program_args, check=True, stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE, text=True)
        print("Program executed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error running the program: {e}")
    except FileNotFoundError:
        print("The program file was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")


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


def render_camera_track_by_direction(camera_track, render_direction):
    print(f'render_camera_track({camera_track.name}, {render_direction})')
    armature_kid_animation_tracks = get_animation_tracks_rig_kid()
    mute_animation_tracks(name_object_rotation)
    camera_track.mute = False
    set_render_direction(render_direction)

    if camera_track.name == name_camera_track_front:
        set_render_frames(1, 8)
        unmute_rotation_track(name_rotation_track_1)
        for rig_kid_animation_track in armature_kid_animation_tracks:
            rig_kid_animation_track.mute = rig_kid_animation_track.name != 'idle'

    if camera_track.name == name_camera_track_isometric:
        set_render_frames(1, 64)
        unmute_rotation_track(name_rotation_track_8)
        # for rig_kid_animation_track in armature_kid_animation_tracks:
        #     rig_kid_animation_track.mute = rig_kid_animation_track.name == 'tpose'

    armature_kid_animation_tracks = object_animation_tracks_active(get_object(name_object_armature_kid))
    exports = get_collection(name_collection_exports)

    if not armature_kid_animation_tracks:
        raise ValueError('armature_kid_animation_tracks not found')

    exports.hide_render = False

    for armature_kid_animation_track in armature_kid_animation_tracks:

        enable_animation_tracks_by_name(armature_kid_animation_track.name)
        active_exports = get_render_active_children(exports)

        if not active_exports:
            raise ValueError('active_children is null')

        for active_export in active_exports:
            active_export.hide_render = True

        for active_export in active_exports:
            active_export.hide_render = False

            render_enabled_meshes = []

            for obj in active_export.objects:
                if not obj.hide_render:
                    render_enabled_meshes.append(obj)
                    obj.hide_render = True

            print('<render_enabled_meshes>')
            for obj in render_enabled_meshes:
                print(obj.name)

            print('</render_enabled_meshes>')

            for obj in render_enabled_meshes:
                obj.hide_render = False
                object_name = obj.name.replace(active_export.name + "_", "")
                mesh_directory = os.path.join(
                    get_render_directory_for_camera_track(camera_track) + "/kid/" + render_direction + "/",
                    active_export.name, object_name, armature_kid_animation_track.name
                )
                os.makedirs(mesh_directory, exist_ok=True)
                set_render_path(os.path.join(mesh_directory, ""))
                render()
                render_false(obj)
                obj.hide_render = True

            active_export.hide_render = True

            for obj in render_enabled_meshes:
                obj.hide_render = False

        for active_export in active_exports:
            active_export.hide_render = False

        armature_kid_animation_track.mute = True

    for armature_kid_animation_track in armature_kid_animation_tracks:
        armature_kid_animation_track.mute = False


def assign_cell_shade_operation_west():
    assign_cell_shade_operation('LESS_THAN')


def assign_cell_shade_north():
    assign_cell_shade_operation('LESS_THAN')


def assign_cell_shade_operation_south():
    assign_cell_shade_operation('GREATER_THAN')


def assign_cell_shade_operation(operation):
    material = bpy.data.materials.get("cell_shade")

    if material is None:
        raise ValueError('failed to set material cell_shade')

    nodes = material.node_tree.nodes

    for node in nodes:
        if not node.type == 'MATH':
            continue

        if node.operation == 'GREATER_THAN':
            node.operation = operation
            node.inputs[1].default_value = 0.15
            return

        if node.operation == 'LESS_THAN':
            node.operation = operation
            node.inputs[1].default_value = -0.15
            return

    raise ValueError('could not find math node')


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


def render_unmuted_rotation_tracks():
    print('render_unmuted_rotation_tracks()')
    set_render_engine_eevee()
    unmuted_camera_tracks = object_animation_tracks_active(get_object(name_object_camera))
    active_direction_tracks = object_animation_tracks_active(get_object(name_object_direction))

    if not unmuted_camera_tracks:
        raise ValueError('no active camera animation tracks')

    for unmuted_camera_track in unmuted_camera_tracks:
        unmuted_camera_track.mute = True

    for unmuted_camera_track in unmuted_camera_tracks:
        for active_direction_track in active_direction_tracks:
            render_camera_track_by_direction(unmuted_camera_track, active_direction_track.name)

    for unmuted_camera_track in unmuted_camera_tracks:
        unmuted_camera_track.mute = False


render_unmuted_rotation_tracks()
active_animation_tracks_render = object_animation_tracks_active(get_object(name_object_render))

for track in active_animation_tracks_render:
    if not track.mute:
        build_sprites_from_renders()

set_render_path("c:/tmp/")
print('render sprites complete')
