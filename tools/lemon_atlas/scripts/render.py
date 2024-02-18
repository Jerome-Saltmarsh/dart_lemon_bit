
import bpy
import os


def getUnmutedAnimationTracks(object_name):
    obj = bpy.data.objects.get(object_name)
    unmuted_tracks = []

    if obj and obj.animation_data:
        for track in obj.animation_data.nla_tracks:
            if not track.mute:
                unmuted_tracks.append(track)

    return unmuted_tracks

def get_visible_children(collection):
    visible_children = []

    if collection:
        view_layer = bpy.context.view_layer
        for child_collection in collection.children:
            if not child_collection.hide_render:
                visible_children.append(child_collection)

    return visible_children

animation_tracks = getUnmutedAnimationTracks("Rig Kid")
exports_collection = bpy.data.collections.get("Exports")

if exports_collection and animation_tracks:
    for track in animation_tracks:
        track.mute = True

    for track in animation_tracks:
        track.mute = False
        exports_collection.hide_render = False
        output_root = "c:/tmp/amulet/kid/"

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

                    mesh_directory = os.path.join(output_root, collection.name, obj.name, track.name)
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

output_root = "c:/tmp"  # Complete this line with the appropriate value

#try:
#    subprocess.run(["c:/tools/dart-sdk/bin/dart", "c:/tmp/test.dart"])
#except subprocess.CalledProcessError as e:
#    print("Error executing Dart script:", e)
