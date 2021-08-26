/*
*
*   raylib [core] example - 2d camera platformer
*
*   This example has been created using raylib 2.5 (www.raylib.com)
*   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
*
*   Example contributed by arvyy (@arvyy) and reviewed by Ramon Santamaria (@raysan5)
*
*   Copyright (c) 2019 arvyy (@arvyy)
*
*   Ported to Jai by @kevinwatters
*
********************************************************************************************/

#import "raylib";
#import "raymath";
#import "Basic";

G :: 400;
PLAYER_JUMP_SPD :: 350;
PLAYER_HOR_SPD :: 200;

Player :: struct {
    position: Vector2;
    speed: float;
    canJump: bool;
}

EnvItem :: struct {
    rect: Rectangle;
    blocking: int;
    color: Color;
}

main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth :: 800;
    screenHeight :: 450;
    
    InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera");
    defer CloseWindow();        // Close window and OpenGL context

    player: Player;
    player.position = Vector2.{ 400, 280 };
    player.speed = 0;
    player.canJump = false;
    envItems: [..]EnvItem;
    array_add(*envItems,
        EnvItem.{.{ 0, 0, 1000, 400 },   0, LIGHTGRAY },
        EnvItem.{.{ 0, 400, 1000, 200 }, 1, GRAY },
        EnvItem.{.{ 300, 200, 400, 10 }, 1, GRAY },
        EnvItem.{.{ 250, 300, 100, 10 }, 1, GRAY },
        EnvItem.{.{ 650, 300, 100, 10 }, 1, GRAY }
    );
    
    camera: Camera2D;
    camera.target = player.position;
    camera.offset = Vector2.{ cast(float)screenWidth/2.0, cast(float)screenHeight/2.0 };
    camera.rotation = 0.0;
    camera.zoom = 1.0;

    // Store pointers to the multiple update camera functions

    CameraFunc :: #type (camera: *Camera2D, player: *Player, items: []EnvItem, delta: float, w: int, h: int);

    cameraUpdaters: []CameraFunc = .[
        UpdateCameraCenter,
        UpdateCameraCenterInsideMap,
        UpdateCameraCenterSmoothFollow,
        UpdateCameraEvenOutOnLanding,
        UpdateCameraPlayerBoundsPush
    ];
    
    cameraOption := 0;
    
    cameraDescriptions := string.[
        "Follow player center",
        "Follow player center, but clamp to map edges",
        "Follow player center; smoothed",
        "Follow player center horizontally; updateplayer center vertically after landing",
        "Player push camera on getting too close to screen edge"
    ];
    
    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while !WindowShouldClose()
    {
        // Update
        //----------------------------------------------------------------------------------
        deltaTime := GetFrameTime();
        
        UpdatePlayer(*player, envItems, deltaTime);

        camera.zoom += (cast(float)GetMouseWheelMove()*0.05);
        
        if camera.zoom > 3.0 camera.zoom = 3.0;
        else if camera.zoom < 0.25 camera.zoom = 0.25;
        
        if IsKeyPressed(.KEY_R)
        {
            camera.zoom = 1.0;
            player.position = Vector2.{ 400, 280 };
        }

        if IsKeyPressed(.KEY_C) cameraOption = (cameraOption + 1) % cameraUpdaters.count;

        // Call update camera function by its pointer
        cameraUpdaters[cameraOption](*camera, *player, envItems, deltaTime, screenWidth, screenHeight);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(LIGHTGRAY);

            {
                BeginMode2D(camera);
                defer EndMode2D();

                for * envItems
                    DrawRectangleRec(it.rect, it.color);

                playerRect:Rectangle;
                playerRect.x = player.position.x - 20;
                playerRect.y = player.position.y - 40;
                playerRect.width = 40;
                playerRect.height = 40;

                DrawRectangleRec(playerRect, RED);
            }

            DrawText("Controls:", 20, 20, 10, BLACK);
            DrawText("- Right/Left to move", 40, 40, 10, DARKGRAY);
            DrawText("- Space to jump", 40, 60, 10, DARKGRAY);
            DrawText("- Mouse Wheel to Zoom in-out, R to reset zoom", 40, 80, 10, DARKGRAY);
            DrawText("- C to change camera mode", 40, 100, 10, DARKGRAY);
            DrawText("Current camera mode:", 20, 120, 10, BLACK);

            desc := to_c_string(cameraDescriptions[cameraOption]);
            defer free(desc);
            DrawText(desc, 40, 140, 10, DARKGRAY);
            
        }
        //----------------------------------------------------------------------------------
    }
}

UpdatePlayer :: (player: *Player, envItems: []EnvItem, delta: float)
{
    if IsKeyDown(.KEY_LEFT) player.position.x -= PLAYER_HOR_SPD * delta;
    if IsKeyDown(.KEY_RIGHT) player.position.x += PLAYER_HOR_SPD * delta;
    if IsKeyDown(.KEY_SPACE) && player.canJump
    {
        player.speed = -PLAYER_JUMP_SPD;
        player.canJump = false;
    }

    hitObstacle := 0;

    for * envItems
    {
        p := *player.position;
        if it.blocking &&
           it.rect.x <= p.x && it.rect.x + it.rect.width >= p.x &&
           it.rect.y >= p.y && it.rect.y < p.y + player.speed * delta
        {
            hitObstacle = 1;
            player.speed = 0.0;
            p.y = it.rect.y;
        }
    }
    
    if !hitObstacle
    {
        player.position.y += player.speed * delta;
        player.speed += G * delta;
        player.canJump = false;
    } 
    else player.canJump = true;
}

UpdateCameraCenter :: (camera: *Camera2D, player: *Player, envItems: []EnvItem, delta: float, width: int, height: int)
{
    camera.offset = make_Vector2(width/2, height/2);
    camera.target = player.position;
}

UpdateCameraCenterInsideMap :: (camera: *Camera2D, player: *Player, envItems: []EnvItem, delta: float, width: int, height: int)
{
    camera.target = player.position;
    camera.offset = make_Vector2(width/2, height/2);

    minX :float = 1000;
    minY :float = 1000;
    maxX :float = -1000;
    maxY :float = -1000;
    
    for * envItems {
        minX = min(it.rect.x, minX);
        maxX = max(it.rect.x + it.rect.width, maxX);
        minY = min(it.rect.y, minY);
        maxY = max(it.rect.y + it.rect.height, maxY);
    }
    
    max_val := GetWorldToScreen2D(make_Vector2(maxX, maxY), << camera);
    min_val := GetWorldToScreen2D(make_Vector2(minX, minY), << camera);
    
    if max_val.x < cast(float)width camera.offset.x = width - (max_val.x - width/2);
    if max_val.y < cast(float)height camera.offset.y = height - (max_val.y - height/2);
    if min_val.x > 0 camera.offset.x = width/2 - min_val.x;
    if min_val.y > 0 camera.offset.y = height/2 - min_val.y;
}

UpdateCameraCenterSmoothFollow :: (camera: *Camera2D, player: *Player, envItems: []EnvItem, delta: float, width: int, height: int)
{
    minSpeed :: 30.0;
    minEffectLength :: 10.0;
    fractionSpeed :: 0.8;
    
    camera.offset = make_Vector2(width/2, height/2);
    diff := Vector2Subtract(player.position, camera.target);
    length := Vector2Length(diff);
    
    if length > minEffectLength
    {
        speed := max(fractionSpeed*length, minSpeed);
        camera.target = Vector2Add(camera.target, Vector2Scale(diff, speed*delta/length));
    }
}

even_out_state: struct {
    eveningOut: int;
    evenOutTarget: float;
};

UpdateCameraEvenOutOnLanding :: (camera: *Camera2D, player: *Player, envItems: []EnvItem, delta: float, width: int, height: int)
{
    using even_out_state;

    evenOutSpeed :: 700;
    
    camera.offset = make_Vector2(width/2, height/2);
    camera.target.x = player.position.x;
    
    if eveningOut
    {
        if evenOutTarget > camera.target.y
        {
            camera.target.y += evenOutSpeed*delta;
            
            if camera.target.y > evenOutTarget
            {
                camera.target.y = evenOutTarget;
                eveningOut = 0;
            }
        } 
        else 
        {
            camera.target.y -= evenOutSpeed*delta;
            
            if camera.target.y < evenOutTarget
            {
                camera.target.y = evenOutTarget;
                eveningOut = 0;
            }
        }
    } 
    else 
    {
        if player.canJump && (player.speed == 0) && (player.position.y != camera.target.y)
        {
            eveningOut = 1;
            evenOutTarget = player.position.y;
        }
    }
}

UpdateCameraPlayerBoundsPush :: (camera: *Camera2D, player: *Player, envItems: []EnvItem, delta: float, width: int, height: int)
{
    bbox: Vector2 = .{ 0.2, 0.2 };

    bboxWorldMin := GetScreenToWorld2D(make_Vector2((1 - bbox.x)*0.5*width, (1 - bbox.y)*0.5*height ), << camera);
    bboxWorldMax := GetScreenToWorld2D(make_Vector2((1 + bbox.x)*0.5*width, (1 + bbox.y)*0.5*height ), << camera);
    camera.offset = make_Vector2((1 - bbox.x)*0.5 * width, (1 - bbox.y)*0.5*height);

    if player.position.x < bboxWorldMin.x camera.target.x = player.position.x;
    if player.position.y < bboxWorldMin.y camera.target.y = player.position.y;
    if player.position.x > bboxWorldMax.x camera.target.x = bboxWorldMin.x + (player.position.x - bboxWorldMax.x);
    if player.position.y > bboxWorldMax.y camera.target.y = bboxWorldMin.y + (player.position.y - bboxWorldMax.y);
}