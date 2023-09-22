import bpy
import os
import sys


def add_current_directory_to_path():
    current_dir = os.path.dirname(bpy.data.filepath)
    if current_dir not in sys.path:
        sys.path.append(current_dir)


def get_unmuted_animation_tracks(object_name):
    object_found = bpy.data.objects.get(object_name)
    unmuted_tracks = []

    if object_found and object_found.animation_data:
        for animation_track in object_found.animation_data.nla_tracks:
            if not animation_track.mute:
                unmuted_tracks.append(animation_track)

    return unmuted_tracks


def get_visible_children(children):
    visible_children = []
    if children:
        for child_collection in children.children:
            if not child_collection.hide_render:
                visible_children.append(child_collection)

    return visible_children


def set_render_engine_eevee():
    bpy.context.scene.render.engine = 'BLENDER_EEVEE'


add_current_directory_to_path()
set_render_engine_eevee()
mesh_obj = bpy.data.objects.get('Mesh Kid')
scene = bpy.context.scene
scene.frame_start = 1
scene.frame_end = 64

if mesh_obj:
    mesh_obj.hide_render = True

camera_tracks = get_unmuted_animation_tracks("Camera")

if camera_tracks:
    if len(camera_tracks) > 1:
        raise ValueError('camera_front and camera_isometric cannot both be active')


def perform_render():
    animation_tracks = get_unmuted_animation_tracks("Rig Kid")
    exports_collection = bpy.data.collections.get("Exports")
    if exports_collection and animation_tracks:
        for track in animation_tracks:
            track.mute = True

        for track in animation_tracks:
            track.mute = False
            exports_collection.hide_render = False
            bpy.context.scene.render.filepath = "C:/Users/Jerome/github/bleed/lemon_atlas/assets/renders/isometric/kid/"

            active_children = get_visible_children(exports_collection)

            if active_children:
                for collection in active_children:
                    collection.hide_render = True
                    for obj in collection.objects:
                        obj.hide_render = True
                        if obj.children:
                            for child_obj in obj.children:
                                child_obj.hide_render = True

                for collection in active_children:
                    collection.hide_render = False
                    for obj in collection.objects:
                        obj.hide_render = False
                        if obj.type == 'MESH':
                            if obj.children:
                                for child_obj in obj.children:
                                    child_obj.hide_render = False

                        object_name = obj.name.replace(collection.name + "_", "")
                        mesh_directory = os.path.join("C:/Users/Jerome/github/bleed/lemon_atlas/assets/renders/isometric/kid/", collection.name, object_name, track.name)
                        os.makedirs(mesh_directory, exist_ok=True)
                        bpy.context.scene.render.filepath = os.path.join(mesh_directory, "")
                        bpy.ops.render.render(animation=True)
                        obj.hide_render = True

                        if obj.type == 'MESH':
                            if obj.children:
                                for child_obj in obj.children:
                                    child_obj.hide_render = True

                    collection.hide_render = True

                for collection in active_children:
                    collection.hide_render = False
                    for obj in collection.objects:
                        obj.hide_render = False
                        if obj.children:
                            for child_obj in obj.children:
                                child_obj.hide_render = False

            track.mute = True

        for track in animation_tracks:
            track.mute = False


perform_render()

output_root = "c:/tmp"
bpy.context.scene.render.filepath = "c:/tmp/"
