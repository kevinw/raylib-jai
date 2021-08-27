/*
*
*   raylib [textures] example - Texture loading and drawing a part defined by a rectangle
*
*   This example has been created using raylib 1.3 (www.raylib.com)
*   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
*
*   Copyright (c) 2014 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

#import "raylib";
#import "Basic";
#import "Math";

MAX_FRAME_SPEED     :: 15;
MIN_FRAME_SPEED     :: 1;

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth :: 800;
    screenHeight :: 450;

    InitWindow(screenWidth, screenHeight, "raylib [texture] example - texture rectangle");
    defer CloseWindow();

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    scarfy := LoadTexture("resources/scarfy.png");        // Texture loading
    defer UnloadTexture(scarfy);

    position := Vector2.{ 350.0, 280.0 };
    frameRec := make_Rectangle(0, 0, cast(float)scarfy.width/6.0, cast(float)scarfy.height);

    currentFrame := 0;

    framesCounter := 0;
    framesSpeed := 8;            // Number of spritesheet frames shown by second

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while !WindowShouldClose()    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        framesCounter += 1;

        if framesCounter >= (60/framesSpeed) {
            framesCounter = 0;
            currentFrame += 1;

            if (currentFrame > 5) currentFrame = 0;

            frameRec.x = cast(float)currentFrame * cast(float)scarfy.width/6;
        }

        if IsKeyPressed(.KEY_RIGHT) framesSpeed += 1;
        else if IsKeyPressed(.KEY_LEFT) framesSpeed -= 1;

        if framesSpeed > MAX_FRAME_SPEED framesSpeed = MAX_FRAME_SPEED;
        else if framesSpeed < MIN_FRAME_SPEED framesSpeed = MIN_FRAME_SPEED;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            DrawTexture(scarfy, 15, 40, WHITE);
            DrawRectangleLines(15, 40, scarfy.width, scarfy.height, LIME);
            DrawRectangleLines(15 + cast(s32)frameRec.x, 40 + cast(s32)frameRec.y, cast(s32)frameRec.width, cast(s32)frameRec.height, RED);

            DrawText("FRAME SPEED: ", 165, 210, 10, DARKGRAY);
            DrawText(TextFormat("%02i FPS", framesSpeed), 575, 210, 10, DARKGRAY);
            DrawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 240, 10, DARKGRAY);

            for i: 0..MAX_FRAME_SPEED - 1 {
                if i < framesSpeed DrawRectangle(250 + 21*cast(s32)i, 205, 20, 20, RED);
                DrawRectangleLines(250 + 21*cast(s32)i, 205, 20, 20, MAROON);
            }

            DrawTextureRec(scarfy, frameRec, position, WHITE);  // Draw part of the texture

            DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, GRAY);
        }
        //----------------------------------------------------------------------------------
    }
}