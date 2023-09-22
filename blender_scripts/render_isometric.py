import bpy
import os
import sys


def add_current_directory_to_path():
    current_dir = os.path.dirname(bpy.data.filepath)
    if current_dir not in sys.path:
        sys.path.append(current_dir)


def get_animation_tracks(object_name):
    animation_object = get_object(object_name)
    if animation_object:
        return animation_object.animation_data.nla_tracks
    raise ValueError('get_animation_tracks("' + object_name + '") is null')


def get_animation_tracks_unmuted(object_name):
    unmuted_tracks = []
    animation_tracks = get_animation_tracks(object_name)
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


def get_collection(collection_name):
    return bpy.data.collections.get(collection_name)


def render():
    bpy.ops.render.render(animation=True)


def set_render_path(value):
    bpy.context.scene.render.filepath = value


def get_animation_tracks_rig_kid():
    return get_animation_tracks("Rig Kid")


def set_animation_track_muted(object_name, track_name, value):
    animation_tracks = get_animation_tracks(object_name)
    if animation_tracks:
        for animation_track in animation_tracks:
            if animation_track.name == track_name:
                animation_track.mute = value
                return


def set_render_frames(start, end):
    scene = bpy.context.scene
    scene.frame_start = start
    scene.frame_end = end


def unmute_camera_pivot_track(pivot_track_name):
    camera_pivot_tracks = get_animation_tracks("Camera Pivot")
    if camera_pivot_tracks:
        for camera_pivot_track in camera_pivot_tracks:
            camera_pivot_track.mute = camera_pivot_track.name != pivot_track_name


def mute_animation_tracks(object_name):
    animation_tracks = get_animation_tracks(object_name)
    if animation_tracks:
        for animation_track in animation_tracks:
            animation_track.mute = True


# BUSINESS LOGIC

def prepare_render(camera_track):
    set_render_engine_eevee()
    hide_mesh_kid()
    rig_kid_animation_tracks = get_animation_tracks_rig_kid()
    mute_camera_pivot_tracks()
    camera_track.mute = False

    if camera_track.name == 'camera_front':
        set_render_frames(1, 8)
        unmute_camera_pivot_track('camera_1')
        for rig_kid_animation_track in rig_kid_animation_tracks:
            rig_kid_animation_track.mute = rig_kid_animation_track.name != 'idle'

    if camera_track.name == 'camera_isometric':
        set_render_frames(1, 64)
        unmute_camera_pivot_track('camera_8')
        for rig_kid_animation_track in rig_kid_animation_tracks:
            rig_kid_animation_track.mute = rig_kid_animation_track.name == 'tpose'


def mute_camera_pivot_tracks():
    mute_animation_tracks("Camera Pivot")


def hide_mesh_kid():
    mesh_obj = get_object('Mesh Kid')
    if mesh_obj:
        mesh_obj.hide_render = True


def render_mode_front(camera_track):
    return camera_track.name == 'camera_front'


def get_render_directory(camera_track):
    dir_renders = 'C:/Users/Jerome/github/bleed/lemon_atlas/assets/renders'
    if render_mode_front(camera_track):
        return dir_renders + '/front'
    else:
        return dir_renders + '/isometric'


def render_camera_track(camera_track):
    prepare_render(camera_track)
    rig_kid_animation_tracks = get_animation_tracks_unmuted("Rig Kid")
    collections_export = get_collection("Exports")

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
                            get_render_directory(camera_track) + "/kid/",
                            collection.name, object_name, track.name
                        )
                        os.makedirs(mesh_directory, exist_ok=True)
                        set_render_path(os.path.join(mesh_directory, ""))
                        render()
                        render_false(obj)

                    collection.hide_render = True

                for collection in active_children:
                    render_true(collection)

            track.mute = True

        for track in rig_kid_animation_tracks:
            track.mute = False


def render_unmuted_camera_tracks():
    unmuted_camera_tracks = get_animation_tracks_unmuted('Camera')

    if not unmuted_camera_tracks:
        raise ValueError('no active camera animations')

    for unmuted_camera_track in unmuted_camera_tracks:
        unmuted_camera_track.mute = True
    for unmuted_camera_track in unmuted_camera_tracks:
        render_camera_track(unmuted_camera_track)
    for unmuted_camera_track in unmuted_camera_tracks:
        unmuted_camera_track.mute = False


render_unmuted_camera_tracks()
set_render_path("c:/tmp")
