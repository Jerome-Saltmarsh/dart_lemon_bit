import bpy

object_type_armature = 'ARMATURE'
render_engine_eevee = 'BLENDER_EEVEE'
render_engine_cycles = 'CYCLES'


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


def get_unmuted(mutables):
    unmuted = []
    for mutable in mutables:
        if not mutable.mute:
            unmuted.append(mutable)
    return unmuted


def object_animation_tracks_active(obj):
    unmuted_tracks = []
    animation_tracks = object_animation_tracks(obj)
    for animation_track in animation_tracks:
        if not animation_track.mute:
            unmuted_tracks.append(animation_track)

    return unmuted_tracks


def get_render_active_children(children):
    visible_children = []
    for child_collection in children.children:
        if not child_collection.hide_render:
            visible_children.append(child_collection)
    return visible_children


def set_render_engine(value):
    bpy.context.scene.render.engine = value


def set_render_engine_eevee():
    set_render_engine(render_engine_eevee)


def set_render_engine_cycles():
    set_render_engine(render_engine_cycles)


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
        raise ValueError(f'get_object({object_name}) - not found')
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
    print(f'blender_utils.set_render_path({value})')
    bpy.context.scene.render.filepath = value


def scene_armatures():
    return find_objects_by_type(object_type_armature)


def object_is_type_armature(obj):
    return obj.type == object_type_armature


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
