import bpy
import os
import subprocess

print('current_dir: ' + os.path.dirname(bpy.data.filepath))


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


def get_render_active_children_2(value):
    if not value:
        raise ValueError('get_render_active_children_2(null)')

    visible_children = []
    children = value.children

    if children:
        for child in children:
            if not child.hide_render:
                visible_children.append(child)

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
    return get_animation_tracks("armature_kid")


def get_armatures():
    return [obj for obj in bpy.context.scene.objects if obj.type == 'ARMATURE']


def get_armatures_render_enabled():
    return [armature for armature in get_armatures() if not armature.hide_render]


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

def build_sprites_from_renders():
    print('build_sprites_from_renders()')
    program_path = r'C:\Users\Jerome\github\bleed\lemon_atlas\build\windows\runner\Release\lemon_sprites.exe'
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
    mesh_obj = get_object('mesh_kid')
    if mesh_obj:
        mesh_obj.hide_render = True


def get_render_directory(camera_track):
    return 'C:/Users/Jerome/github/bleed/lemon_atlas/assets/renders/' + camera_track.name


def get_character_armatures():
    return [armature for armature in get_armatures() if armature.name.startswith('armature')]


def enable_animation_tracks_by_name(name):
    for armature in get_character_armatures():
        animation_tracks = armature.animation_data.nla_tracks
        for animation_track in animation_tracks:
            animation_track.mute = animation_track.name != name


def render_camera_track(camera_track):
    print(f'render_camera_track({camera_track.name})')
    armature_kid_animation_tracks = get_animation_tracks_rig_kid()
    mute_animation_tracks("Camera Pivot")
    camera_track.mute = False

    if camera_track.name == 'front':
        set_render_frames(1, 8)
        unmute_camera_pivot_track('camera_1')
        for rig_kid_animation_track in armature_kid_animation_tracks:
            rig_kid_animation_track.mute = rig_kid_animation_track.name != 'idle'

    if camera_track.name == 'isometric':
        set_render_frames(1, 64)
        unmute_camera_pivot_track('camera_8')
        for rig_kid_animation_track in armature_kid_animation_tracks:
            rig_kid_animation_track.mute = rig_kid_animation_track.name == 'tpose'

    armature_kid_animation_tracks = get_animation_tracks_unmuted("armature_kid")
    exports = get_collection("exports")

    if not exports:
        raise ValueError('exports not found')

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

            for obj in render_enabled_meshes:
                obj.hide_render = False
                object_name = obj.name.replace(active_export.name + "_", "")
                mesh_directory = os.path.join(
                    get_render_directory(camera_track) + "/kid/",
                    active_export.name, object_name, armature_kid_animation_track.name
                )
                os.makedirs(mesh_directory, exist_ok=True)
                set_render_path(os.path.join(mesh_directory, ""))
                render()
                render_false(obj)
                obj.hide_render = True

            active_export.hide_render = True

        for active_export in active_exports:
            active_export.hide_render = False

        armature_kid_animation_track.mute = True

    for armature_kid_animation_track in armature_kid_animation_tracks:
        armature_kid_animation_track.mute = False


def render_unmuted_camera_tracks():
    print('render_unmuted_camera_tracks()')
    hide_mesh_kid()
    set_render_engine_eevee()
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
build_sprites_from_renders()
set_render_path("c:/tmp")
print('render sprites complete')
