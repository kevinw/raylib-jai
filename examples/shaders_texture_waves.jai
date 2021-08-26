/*
*
*   raylib [shaders] example - Texture Waves
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
*         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
*         raylib comes with shaders ready for both versions, check raylib/shaders install folder
*
*   This example has been created using raylib 2.5 (www.raylib.com)
*   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
*
*   Example contributed by Anata (@anatagawa) and reviewed by Ramon Santamaria (@raysan5)
*
*   Copyright (c) 2019 Anata (@anatagawa) and Ramon Santamaria (@raysan5)
*
********************************************************************************************/

#load "../raylib.jai";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else
    GLSL_VERSION :: 100;

main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth :: 800;
    screenHeight :: 450;

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - texture waves");
    defer CloseWindow();
    
    // Load texture texture to apply shaders
    texture := LoadTexture("resources/space.png");
    defer UnloadTexture(texture);       // Unload texture
    
    // Load shader and setup location points and values
    shader := LoadShader(null, TextFormat("resources/shaders/glsl%i/wave.fs", GLSL_VERSION));
    defer UnloadShader(shader);

    secondsLoc := GetShaderLocation(shader, "secondes");
    freqXLoc := GetShaderLocation(shader, "freqX");
    freqYLoc := GetShaderLocation(shader, "freqY");
    ampXLoc := GetShaderLocation(shader, "ampX");
    ampYLoc := GetShaderLocation(shader, "ampY");
    speedXLoc := GetShaderLocation(shader, "speedX");
    speedYLoc := GetShaderLocation(shader, "speedY");

    // Shader uniform values that can be updated at any time
    freqX:float = 25.0;
    freqY:float = 25.0;
    ampX:float = 5.0;
    ampY:float = 5.0;
    speedX:float = 8.0;
    speedY:float = 8.0;

    screenSize: [2]float;
    screenSize[0] = cast(float)GetScreenWidth();
    screenSize[1] = cast(float)GetScreenHeight();
    SetShaderValue(shader, GetShaderLocation(shader, "size"), *screenSize, .UNIFORM_VEC2);
    SetShaderValue(shader, freqXLoc, *freqX, .UNIFORM_FLOAT);
    SetShaderValue(shader, freqYLoc, *freqY, .UNIFORM_FLOAT);
    SetShaderValue(shader, ampXLoc, *ampX, .UNIFORM_FLOAT);
    SetShaderValue(shader, ampYLoc, *ampY, .UNIFORM_FLOAT);
    SetShaderValue(shader, speedXLoc, *speedX, .UNIFORM_FLOAT);
    SetShaderValue(shader, speedYLoc, *speedY, .UNIFORM_FLOAT);

    seconds:float = 0.0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    // -------------------------------------------------------------------------------------------------------------

    // Main game loop
    while !WindowShouldClose()    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        seconds += GetFrameTime();
        
        SetShaderValue(shader, secondsLoc, *seconds, .UNIFORM_FLOAT);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            {
                BeginShaderMode(shader);
                defer EndShaderMode();

                DrawTexture(texture, 0, 0, WHITE);
                DrawTexture(texture, texture.width, 0, WHITE);
            }
        }
        //----------------------------------------------------------------------------------
    }
}