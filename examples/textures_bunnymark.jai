/*
*
*   raylib [textures] example - Bunnymark
*
*   This example has been created using raylib 1.6 (www.raylib.com)
*   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
*
*   Copyright (c) 2014-2019 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

#import "raylib";
#import "Basic";
#import "Math";

MAX_BUNNIES :: 50000;    // 50K bunnies limit

// This is the maximum amount of elements (quads) per batch
// NOTE: This value is defined in [rlgl] module and can be changed there
MAX_BATCH_ELEMENTS :: 8192;

Bunny :: struct {
    position: Vector2;
    speed: Vector2;
    color: Color;
}

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth :: 800;
    screenHeight :: 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - bunnymark");
    defer CloseWindow();

    // Load bunny texture
    texBunny := LoadTexture("resources/wabbit_alpha.png");
    defer UnloadTexture(texBunny);

    bunnies: [..]Bunny;
    array_resize(*bunnies, MAX_BUNNIES);
    defer array_free(bunnies);

    bunniesCount := 0;           // Bunnies counter

    SetTargetFPS(60);            // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while !WindowShouldClose()   // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if IsMouseButtonDown(.MOUSE_LEFT_BUTTON)
        {
            // Create more bunnies
            for i: 0..99 {
                if bunniesCount < MAX_BUNNIES {
                    bunnies[bunniesCount].position = GetMousePosition();
                    bunnies[bunniesCount].speed.x = cast(float)GetRandomValue(-250, 250)/60.0;
                    bunnies[bunniesCount].speed.y = cast(float)GetRandomValue(-250, 250)/60.0;
                    bunnies[bunniesCount].color = make_Color(GetRandomValue(50, 240),
                                                          GetRandomValue(80, 240),
                                                          GetRandomValue(100, 240), 255);
                    bunniesCount += 1;
                }
            }
        }

        // Update bunnies
        for * bunnies {
            it.position.x += it.speed.x;
            it.position.y += it.speed.y;

            if ((it.position.x + texBunny.width/2) > cast(float)GetScreenWidth()) ||
                ((it.position.x + texBunny.width/2) < 0) it.speed.x *= -1;
            if ((it.position.y + texBunny.height/2) > cast(float)GetScreenHeight()) ||
                ((it.position.y + texBunny.height/2 - 40) < 0) it.speed.y *= -1;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            for * bunnies {
                // NOTE: When internal batch buffer limit is reached (MAX_BATCH_ELEMENTS),
                // a draw call is launched and buffer starts being filled again;
                // before issuing a draw call, updated vertex data from internal CPU buffer is send to GPU...
                // Process of sending data is costly and it could happen that GPU data has not been completely
                // processed for drawing while new data is tried to be sent (updating current in-use buffers)
                // it could generates a stall and consequently a frame drop, limiting the number of drawn bunnies
                DrawTexture(texBunny, cast(s32)it.position.x, cast(s32)it.position.y, it.color);
            }

            DrawRectangle(0, 0, screenWidth, 40, BLACK);
            DrawText(TextFormat("bunnies: %i", bunniesCount), 120, 10, 20, GREEN);
            DrawText(TextFormat("batched draw calls: %i", 1 + bunniesCount/MAX_BATCH_ELEMENTS), 320, 10, 20, MAROON);

            DrawFPS(10, 10);

        }
    }
}