import bpy


def create_summary(text: str, length: int = 300) -> str:
    return f"Code Preview:\n\n{text[:length]}"


def list_textname_callback(scene, context):
    return [
        (text.name, text.name, create_summary(text.as_string()))
        for text in bpy.data.texts
    ]


class TEXT_OT_run_specified_script(bpy.types.Operator):
    bl_idname = "text.hello_world"
    bl_label = "Hello World"
    bl_options = {'REGISTER'}

    script_name: bpy.props.EnumProperty(
        name="Run script from:",
        description="Run this specified script.",
        items=list_textname_callback
    )

    def invoke(self, context, event):
        bpy.utils.execfile('C:/Users/Jerome/hello.py')
        # script = bpy.data.texts.get('hello_world', None)
        # if script is not None:
        #     print(script.as_string())
        #     # try:
        #     #     exec(
        #     #         compile(
        #     #             script.as_string(),
        #     #             filename=f"{script.name}",
        #     #             mode='exec',
        #     #         ),
        #     #         {},
        #     #         bpy.data,
        #     #     )
        #     # except Exception as e:
        #     #     self.report({'ERROR'}, f"Error executing script: {str(e)}")
        # else:
        #     self.report({'WARNING'}, "No script found.")
        return {'FINISHED'}

    def execute(self, context):
        print('execute()')
        script = bpy.data.texts.get(self.script_name, None)
        if script is not None:
            try:
                exec(
                    compile(
                        script.as_string(),
                        filename=f"{script.name}",
                        mode='exec',
                    ),
                    {},
                    bpy.data,
                )
            except Exception as e:
                self.report({'ERROR'}, f"Error executing script: {str(e)}")
        else:
            self.report({'WARNING'}, "No script found.")
        return {'FINISHED'}


def _menu_func(self, context):
    layout = self.layout
    layout.operator(
        TEXT_OT_run_specified_script.bl_idname,
        text=TEXT_OT_run_specified_script.bl_label,
    )


def register():
    bpy.utils.register_class(TEXT_OT_run_specified_script)
    bpy.types.TOPBAR_MT_render.append(_menu_func)


def unregister():
    bpy.utils.unregister_class(TEXT_OT_run_specified_script)
    bpy.types.TOPBAR_MT_render.remove(_menu_func)


if __name__ == "__main__":
    try:
        unregister()
    except:
        pass
    register()
