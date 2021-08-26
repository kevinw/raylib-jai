/*
*   raylib [core] example - Keyboard input
*
*   This example has been created using raylib 1.0 (www.raylib.com)
*   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
*
*   Copyright (c) 2014 Ramon Santamaria (@raysan5)
*
*   Ported to Jai by @kevinwatters
*
********************************************************************************************/

#import "raylib";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth :: 800;
    screenHeight :: 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - keyboard input");
    defer CloseWindow();

    ballPosition := Vector2.{ cast(float)screenWidth/2, cast(float)screenHeight/2 };

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while !WindowShouldClose()    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        speed := GetFrameTime() * 180.0;
        if IsKeyDown(.KEY_RIGHT) ballPosition.x += speed;
        if IsKeyDown(.KEY_LEFT) ballPosition.x -= speed;
        if IsKeyDown(.KEY_UP) ballPosition.y -= speed;
        if IsKeyDown(.KEY_DOWN) ballPosition.y += speed;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            DrawText("move the ball with arrow keys", 10, 10, 20, DARKGRAY);

            DrawCircleV(ballPosition, 50, MAROON);
        }
        //----------------------------------------------------------------------------------
    }
}