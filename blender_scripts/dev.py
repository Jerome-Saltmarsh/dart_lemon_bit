import bpy


def armature_tracks_mute(value):
    for armature in get_character_armatures():

        animation_tracks = armature.animation_data.nla_tracks

        for animation_track in animation_tracks:
            animation_track.mute = value


def get_armatures():
    return [obj for obj in bpy.context.scene.objects if obj.type == 'ARMATURE']


def get_character_armatures():
    return [armature for armature in get_armatures() if armature.name.startswith('armature')]


def enable_animation_track(name):
    for armature in get_character_armatures():
        animation_tracks = armature.animation_data.nla_tracks
        for animation_track in animation_tracks:
            animation_track.mute = animation_track.name != name


armature_tracks_mute(True)
enable_animation_track('idle')
