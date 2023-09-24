import bpy


def create_summary(text: str, length: int = 300) -> str:
    return f"Code Preview:\n\n{text[:length]}"


def list_textname_callback(scene, context):
    return [
        (text.name, text.name, create_summary(text.as_string()))
        for text in bpy.data.texts
    ]


class TEXT_OT_run_specified_script(bpy.types.Operator):
    bl_idname = "text.render_sprites"
    bl_label = "Render Sprites"
    bl_options = {'REGISTER'}

    script_name: bpy.props.EnumProperty(
        name="Run script from:",
        description="Run this specified script.",
        items=list_textname_callback
    )

    def invoke(self, context, event):
        bpy.utils.execfile('C:/Users/Jerome/github/bleed/blender_scripts/render_isometric.py')
        return {'FINISHED'}


def _menu_func(self, context):
    layout = self.layout
    layout.operator(
        TEXT_OT_run_specified_script.bl_idname,
        text=TEXT_OT_run_specified_script.bl_label,
    )


def run_on_startup(dummy):
    print('installing render_sprites plugin')
    register()


def register():
    bpy.utils.register_class(TEXT_OT_run_specified_script)
    bpy.types.TOPBAR_MT_render.append(_menu_func)

    # Register the function to run on startup
    bpy.app.handlers.load_post.append(run_on_startup)


def unregister():
    bpy.utils.unregister_class(TEXT_OT_run_specified_script)
    bpy.types.TOPBAR_MT_render.remove(_menu_func)

    # Unregister the function from running on startup
    bpy.app.handlers.load_post.remove(run_on_startup)


if __name__ == "__main__":
    try:
        unregister()
    except:
        pass
    register()
