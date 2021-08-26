/*
*
*   raylib [shaders] example - Apply a postprocessing shader and connect a custom uniform variable
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
*         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
*         raylib comes with shaders ready for both versions, check raylib/shaders install folder
*
*   This example has been created using raylib 1.3 (www.raylib.com)
*   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
*
*   Copyright (c) 2015 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

#load "../raylib.jai";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth :: 800;
    screenHeight :: 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT);      // Enable Multi Sampling Anti Aliasing 4x (if available)

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - custom uniform variable");
    defer CloseWindow();                  // Close window and OpenGL context

    // Define the camera to look into our 3d world
    camera := Camera.{
        position = Vector3.{ 8.0, 8.0, 8.0 },
        target = Vector3.{ 0.0, 1.5, 0.0 },
        up = Vector3.{ 0.0, 1.0, 0.0 },
        fovy = 45.0,
        type = .CAMERA_PERSPECTIVE,
    };

    model := LoadModel("resources/models/barracks.obj");                   // Load OBJ model
    defer UnloadModel(model);
    texture := LoadTexture("resources/models/barracks_diffuse.png");   // Load model texture (diffuse map)
    defer UnloadTexture(texture);
    model.materials[0].maps[MaterialMapType.MAP_ALBEDO].texture = texture;                     // Set model diffuse texture

    position := Vector3.{ 0.0, 0.0, 0.0 };                                    // Set model position

    // Load postprocessing shader
    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shader := LoadShader(null, TextFormat("resources/shaders/glsl%i/swirl.fs", GLSL_VERSION));
    defer UnloadShader(shader);

    // Get variable (uniform) location on the shader to connect with the program
    // NOTE: If uniform variable could not be found in the shader, function returns -1
    swirlCenterLoc := GetShaderLocation(shader, "center");

    swirlCenter:[2]float;
    swirlCenter[0] = cast(float)screenWidth/2;
    swirlCenter[1] = cast(float)screenHeight/2;

    // Create a RenderTexture2D to be used for render to texture
    target := LoadRenderTexture(screenWidth, screenHeight);
    defer UnloadRenderTexture(target);

    // Setup orbital camera
    SetCameraMode(camera, .CAMERA_ORBITAL);  // Set an orbital camera mode

    SetTargetFPS(60);                       // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while !WindowShouldClose()              // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        mousePosition := GetMousePosition();

        swirlCenter[0] = mousePosition.x;
        swirlCenter[1] = screenHeight - mousePosition.y;

        // Send new value to the shader to be used on drawing
        SetShaderValue(shader, swirlCenterLoc, *swirlCenter[0], .UNIFORM_VEC2);

        UpdateCamera(*camera);              // Update camera
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginTextureMode(target);       // Enable drawing to texture

                ClearBackground(RAYWHITE);  // Clear texture background

                BeginMode3D(camera);        // Begin 3d mode drawing

                    DrawModel(model, position, 0.5, WHITE);   // Draw 3d model with texture

                    DrawGrid(10, 1.0);     // Draw a grid

                EndMode3D();                // End 3d mode drawing, returns to orthographic 2d mode

                DrawText("TEXT DRAWN IN RENDER TEXTURE", 200, 10, 30, RED);

            EndTextureMode();               // End drawing to texture (now we have a texture available for next passes)

            BeginShaderMode(shader);

                // NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
                DrawTextureRec(target.texture, make_Rectangle(0, 0, target.texture.width, -target.texture.height), Vector2.{ 0, 0 }, WHITE);

            EndShaderMode();

            // Draw some 2d text over drawn texture
            DrawText("(c) Barracks 3D model by Alberto Cano", screenWidth - 220, screenHeight - 20, 10, GRAY);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }
}