import bpy
import os
import sys

dir_renders = 'C:/Users/Jerome/github/bleed/lemon_atlas/assets/renders'


def add_current_directory_to_path():
    current_dir = os.path.dirname(bpy.data.filepath)
    if current_dir not in sys.path:
        sys.path.append(current_dir)


def get_animation_tracks(object_name):
    object_found = bpy.data.objects.get(object_name)
    if object_found:
        return object_found.animation_data.nla_tracks
    raise ValueError('could not find animation object ' + object_name)


def get_unmuted_animation_tracks(object_name):
    object_found = bpy.data.objects.get(object_name)
    unmuted_tracks = []

    if object_found and object_found.animation_data:
        for animation_track in object_found.animation_data.nla_tracks:
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
    set_render_engine('BLENDER_EEVEE')


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
    return bpy.data.objects.get(object_name)


def set_render_path(value):
    bpy.context.scene.render.filepath = value


def prepare_render():
    add_current_directory_to_path()
    set_render_engine_eevee()
    scene = bpy.context.scene
    mesh_obj = get_object('Mesh Kid')
    camera_tracks = get_unmuted_animation_tracks("Camera")
    camera_pivot_tracks = get_animation_tracks("Camera Pivot")
    animation_tracks = get_animation_tracks('Rig Kid')

    if camera_pivot_tracks:
        for camera_pivot_track in camera_pivot_tracks:
            camera_pivot_track.mute = True

    if mesh_obj:
        mesh_obj.hide_render = True

    if camera_tracks:

        for camera_track in camera_tracks:
            camera_track.mute = True

        for camera_track in camera_tracks:
            camera_track.mute = False
            if camera_track.name == 'camera_front':
                scene.frame_start = 1
                scene.frame_end = 8

                if camera_pivot_tracks:
                    for camera_pivot_track in camera_pivot_tracks:
                        camera_pivot_track.mute = camera_pivot_track.name != 'camera_1'

                if animation_tracks:
                    for animation_track in animation_tracks:
                        animation_track.mute = animation_track.name != 'idle'

            if camera_track.name == 'camera_isometric':
                scene.frame_start = 1
                scene.frame_end = 64

                if camera_pivot_tracks:
                    for camera_pivot_track in camera_pivot_tracks:
                        camera_pivot_track.mute = camera_pivot_track.name != 'camera_8'

                if animation_tracks:
                    for animation_track in animation_tracks:
                        animation_track.mute = animation_track.name == 'tpose'

            camera_track.mute = True

        for camera_track in camera_tracks:
            camera_track.mute = False


def render_mode_front():
    unmuted_tracks = get_unmuted_animation_tracks("Camera")
    for unmuted_track in unmuted_tracks:
        if unmuted_track.name == 'camera_front':
            return True
    return False


def get_render_target():
    if render_mode_front():
        return dir_renders + '/front'
    else:
        return dir_renders + '/isometric'


def perform_render():
    rig_kid_animation_tracks = get_unmuted_animation_tracks("Rig Kid")
    collections_export = bpy.data.collections.get("Exports")

    if collections_export and rig_kid_animation_tracks:
        for track in rig_kid_animation_tracks:
            track.mute = True

        for track in rig_kid_animation_tracks:
            track.mute = False
            collections_export.hide_render = False
            active_children = get_render_active_children(collections_export)

            if active_children:
                for collection in active_children:
                    render_false(collection)

                for collection in active_children:
                    collection.hide_render = False
                    for obj in collection.objects:
                        render_true(obj)
                        object_name = obj.name.replace(collection.name + "_", "")
                        mesh_directory = os.path.join(
                            get_render_target() + "/kid/",
                            collection.name, object_name, track.name
                        )
                        os.makedirs(mesh_directory, exist_ok=True)
                        set_render_path(os.path.join(mesh_directory, ""))
                        bpy.ops.render.render(animation=True)
                        render_false(obj)

                    collection.hide_render = True

                for collection in active_children:
                    render_true(collection)

            track.mute = True

        for track in rig_kid_animation_tracks:
            track.mute = False


prepare_render()
perform_render()
set_render_path("c:/tmp")
