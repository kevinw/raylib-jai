'''

naive regex-based code for turning raylib.h into raylib.jai

'''
import re
import os.path
from io import StringIO

ctx = dict()

def p(*a, **k):
    # a shortcut for printing to the output file
    if "file" not in k and "output_file" in ctx:
        k["file"] = ctx["output_file"]
    print(*a, **k)

enum_flags = set((
    "ConfigFlags",
))

type_replacements = [
    ("const char", "u8"),
    ("const ", ""),
    ("unsigned short", "u16"),
    ("unsigned int", "u32"),
    ("unsigned char", "u8"),
    ("char", "s8"),
    ("long", "s32"),
    ("double", "float64"),
    ("int", "s32"),
    ("Matrix", "Matrix4"),
]

def replace_types(s):
    for c_type, jai_type in type_replacements:
        s = re.sub(r"\b" + c_type + r"\b", jai_type, s)
    return s

def delete_code(s):
    for block in deletion_code:
        s = s.replace(block, "")
    return s

extra_type_code = dict(
    Rectangle = """
    #place x;     position: Vector2;
    #place width; size: Vector2;""",
)

deletion_structs = set(("Vector2", "Vector3", "Vector4", "Matrix", "Quaternion"))

extra_code = """

float16 :: struct { v: [16]float; }

// TODO: parse rlgl.h and generate rlgl.jai separately
MatrixToFloatV  :: (mat: Matrix4) -> float16 #foreign raylib_native;
MatrixToFloat   :: (mat: Matrix4) -> *float { return MatrixToFloatV(mat).v.data; };
MatrixTranslate :: (x: float, y: float, z: float) -> Matrix4 #foreign raylib_native;
MatrixRotate    :: (axis: Vector3, angle_radians: float) -> Matrix4 #foreign raylib_native;
MatrixScale     :: (x: float, y: float, z: float) -> Matrix4 #foreign raylib_native;
MatrixMultiply  :: (a: Matrix4, b: Matrix4) -> Matrix4 #foreign raylib_native;

DrawText :: inline ($$text: string, posX: s32, posY: s32, fontSize: s32, color: Color) {
    DrawText(constant_or_temp_cstring(text), posX, posY, fontSize, color);
}

make_Rectangle :: (x: $A, y: $B, width: $C, height: $D) -> Rectangle {
    r: Rectangle;
    r.x      = cast(float)x;
    r.y      = cast(float)y;
    r.width  = cast(float)width;
    r.height = cast(float)height;
    return r;
}

make_Color :: (r: $A, g: $B, b: $C, a: $D) -> Color {
    color: Color;
    color.r = cast(u8)r;
    color.g = cast(u8)g;
    color.b = cast(u8)b;
    color.a = cast(u8)a;
    return color;
}

make_Vector3 :: (x: $A, y: $B, z: $C) -> Vector3 {
    v: Vector3;
    v.x = cast(float)x;
    v.y = cast(float)y;
    v.z = cast(float)z;
    return v;
}

make_Vector2 :: (x: $A, y: $B) -> Vector2 {
    v: Vector2;
    v.x = cast(float)x;
    v.y = cast(float)y;
    return v;
}

// Macros for Begin/End pairs where the EndXXX Function is called automatically
// at the end of the scope.

PushDrawing :: () #expand {
    BeginDrawing();
    `defer EndDrawing();
}

PushMode2D :: (camera: Camera2D) #expand {
    BeginMode2D(camera);
    `defer EndMode2D();
}

PushMode3D :: (camera: Camera3D) #expand {
    BeginMode3D(camera);
    `defer EndMode3D();
}

PushTextureMode :: (target: RenderTexture2D) #expand {
    BeginTextureMode(target);
    `defer EndTextureMode();
}

PushScissorMode :: (x: s32, y: s32, width: s32, height: s32) #expand {
    BeginScissorMode(x, y, width, height);
    `defer EndScissorMode();
}

PushShaderMode :: (shader: Shader) #expand {
    BeginShaderMode(shader);
    `defer EndShaderMode();
}

PushBlendMode :: (mode: s32) #expand {
    BeginBlendMode(mode);
    `defer EndBlendMode();
}

#scope_file
Basic :: #import "Basic";

_to_temp_c_string :: (s: string) -> *u8 {
    result : *u8 = Basic.talloc(s.count + 1);
    memcpy(result, s.data, s.count);
    result[s.count] = 0;
    return result;
}

constant_or_temp_cstring :: inline ($$text: string) -> *u8 {
    c_str: *u8;
    #if is_constant(text)
        c_str = text.data;
    else
        c_str = _to_temp_c_string(text);
    return c_str;
}

TraceLogCallback :: #type (logLevel: TraceLogLevel, text: *u8, args: .. Any);
LoadFileDataCallback :: #type (fileName: *u8, bytesRead: *u32) -> *u8;
SaveFileDataCallback :: #type (fileName: *u8, data: *void, bytesToWrite: u32) -> bool;
LoadFileTextCallback :: #type (fileName: *u8) -> *u8;
SaveFileTextCallback :: #type (fileName: *u8, text: *u8) -> bool;

"""

# TODO: these could be a dictionary of argument types mapping to enum types and
# fuzzy function name matches. or maybe just lists of argument and return types
function_replacements = dict(
    IsKeyPressed  = "(key: KeyboardKey) -> bool",
    IsKeyDown     = "(key: KeyboardKey) -> bool",
    IsKeyReleased = "(key: KeyboardKey) -> bool",
    IsKeyUp       = "(key: KeyboardKey) -> bool",
    SetExitKey    = "(key: KeyboardKey) -> bool",

    IsMouseButtonPressed = "(button: MouseButton) -> bool",
    IsMouseButtonDown = "(button: MouseButton) -> bool",
    IsMouseButtonReleased = "(button: MouseButton) -> bool",
    IsMouseButtonUp = "(button: MouseButton) -> bool",

    SetCameraMode = "(camera: Camera, mode: CameraMode)",

    SetConfigFlags = "(flags: ConfigFlags)",

    SetTraceLogLevel = "(logType: TraceLogLevel)",
    SetTraceLogExit  = "(logType: TraceLogLevel)",

    SetShaderValue  = "(shader: Shader, uniformLoc: s32, value: *void, uniformType: ShaderUniformDataType)",
    SetShaderValueV = "(shader: Shader, uniformLoc: s32, value: *void, uniformType: ShaderUniformDataType, count: s32)",

    IsGamepadButtonPressed  = "(gamepad: int, button: GamepadButton) -> bool",
    IsGamepadButtonDown     = "(gamepad: int, button: GamepadButton) -> bool",
    IsGamepadButtonReleased = "(gamepad: int, button: GamepadButton) -> bool",
    IsGamepadButtonUp       = "(gamepad: int, button: GamepadButton) -> bool",

    GetGamepadAxisMovement  = "(gamepad: int, axis: GamepadAxis) -> float",
)

struct_field_replacements = dict(
    Camera3D = dict(
        projection = "CameraProjection"
    )
)

def generate_jai_bindings():
    header_filename = "raylib/include/raylib.h"
    header = open(header_filename).read()
    native_lib_name = "raylib_native"
    path_to_native_lib = "raylib/lib/raylib"
    output_filename = "raylib.jai"

    ctx["output_file"] = open(output_filename, "w")
    with ctx["output_file"]:

        p("//\n// AUTOGENERATED\n//\n")

        #
        # colors
        #
        for match in re.finditer(r"#define (\w+)\s+CLITERAL\(Color\){([^}]+)}", header):
            color_name = match.group(1)
            values = match.group(2)
            p(f"{color_name} :: Color.{{ {values} }};")

        #
        #  function pointers aren't parsed by regexes yet, so this is the only thing "by hand"
        #
        p("\nTraceLogCallback :: #type (logType: s32, text: *u8, args: ..*u8);\n")

        #
        # enums
        #
        for match in re.finditer(r"typedef enum {([^}]*)} (\w+);", header):
            enum_id = match.group(2).strip()
            if enum_id == "bool":
                continue # skip the C compat bool definition

            enum_contents = match.group(1).strip()\
                .replace("=", "::")\
                .replace(",", ";")

            enum_contents = re.sub(r"//.*$", "", enum_contents)
            # TODO: the above removes the last comment in an enum body...we could probably retain them

            if not enum_contents.endswith(";"):
                enum_contents = enum_contents.rstrip() + ";"

            enum_type = "enum_flags" if enum_id in enum_flags else "enum"

            p(f"{enum_id} :: {enum_type} {{\n    {enum_contents}\n}}\n")

        #
        # aliases
        #
        for match in re.finditer(r"typedef struct (\w+) (\w+);", header):
            struct_id = match.group(2)
            if struct_id in deletion_structs:
                continue
            
            p(f"{struct_id} :: struct {{ /* only used as a pointer in this header */ }}\n")
        
        for match in re.finditer(r"typedef (\w+) (\w+);", header):
            if match.group(1) == "struct":
                continue # handled by loop above

            if match.group(1) in deletion_structs:
                continue;
            
            aliased_struct = match.group(1)
            struct_id = match.group(2)

            p(f"{struct_id} :: {aliased_struct};\n")

        #
        # structs
        #
        for match in re.finditer(r"typedef struct (\w+) {([^}]*)}", header):
            identifier = match.group(1)
            
            if identifier in deletion_structs:
                continue

            struct_contents = StringIO()
            for line in replace_types(match.group(2).strip()).split("\n"):
                field_m = re.search(r"(.*?)((\w+|, )+)(\[\d+\])?;", line)
                if field_m is None: continue

                field_type = replace_types(field_m.group(1).strip())
                pointer_count = 0
                if field_type.endswith(" **"):
                    pointer_count = 2
                    field_type = field_type[:-3]
                if field_type.endswith(" *"):
                    pointer_count = 1
                    field_type = field_type[:-2]
                field_id = field_m.group(2).strip()

                pointer_char = "*" * pointer_count

                field_type = struct_field_replacements.get(identifier, {}).get(field_id, field_type)

                p(f"    {field_id}: {pointer_char}{field_type};", file=struct_contents)
            
            extra = extra_type_code.get(identifier, None)
            if extra is not None:
                p(extra, file=struct_contents)
            
            p(f"{identifier} :: struct {{\n{struct_contents.getvalue()}}}\n")
        
        #
        # functions
        #
        for match in re.finditer(r"RLAPI (.*?)(\w+)\(([^\)]*)\);", header):
            return_type = match.group(1).strip()
            func_name = match.group(2)
            args = match.group(3)

            arg_contents = StringIO()
            if args != "void":
                for arg in args.split(","):
                    tokens = arg.strip().split(" ")
                    arg_name = tokens[-1]
                    arg_type = replace_types(" ".join(tokens[:-1]))
                    pointer_count = 0
                    if arg_name.startswith("**"):
                        pointer_count = 2
                        arg_name = arg_name[2:]
                    if arg_name.startswith("*"):
                        pointer_count = 1
                        arg_name = arg_name[1:]
                    pointer_char = "*" * pointer_count

                    if arg_name == "...":
                        p(f"args: ..*u8", file=arg_contents, end="")
                    else:
                        p(f"{arg_name}: {pointer_char}{arg_type}, ", file=arg_contents, end="")

            arg_contents = arg_contents.getvalue()
            if arg_contents.endswith(", "):
                arg_contents = arg_contents[:-2]

            replacement_string = function_replacements.get(func_name, None)
            if replacement_string != None:
                func_decl = replacement_string
            else:
                if return_type == "void":
                    return_type_string = ""
                else:
                    return_type = replace_types(return_type)
                    if return_type.endswith(" **"):
                        return_type = "**" + return_type[:-3]
                    elif return_type.endswith(" *"):
                        return_type = "*" + return_type[:-2]

                    return_type_string = "-> " + return_type
                func_decl = f"({arg_contents}) {return_type_string}"

            p(f"{func_name} :: {func_decl} #foreign {native_lib_name};")

        p(extra_code)
        
        #
        # native library
        #
        p("\n#scope_file // ---------------\n")
        p("#if OS == .WINDOWS {")
        p("""    #foreign_system_library "user32";""")
        p("""    #foreign_system_library "gdi32";""")
        p("""    #foreign_system_library "shell32";""")
        p("""    #foreign_system_library "winmm";""")
        p(f"    {native_lib_name} :: #foreign_library,no_dll \"{path_to_native_lib}\";")
        p("}")
        p("""#import "Math";""")
    
    print(f"Wrote Jai bindings file '{output_filename}' from C header '{header_filename}'.")


def main():
    # change to script directory
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    generate_jai_bindings()

if __name__ == "__main__":
    main()
