#import "raylib";

Vector2Add :: (a: Vector2, b: Vector2) -> Vector2 {
    r: Vector2 = ---;
    r.x = a.x + b.x;
    r.y = a.y + b.y;
    return r;
}

Vector2Subtract :: (v1: Vector2, v2: Vector2) -> Vector2 {
    r: Vector2 = ---;
    r.x = a.x - b.x;
    r.y = a.y - b.y;
    return r;
}

Vector2Scale :: (v: Vector2, scale: float) -> Vector2 {
    r: Vector2 = ---;
    r.x = v.x * scale;
    r.y = v.y * scale;
    return r;
}

Vector2Length :: (v: Vector2) -> float {
    return Math.sqrt((v.x*v.x) + (v.y*v.y));
}

operator + :: Vector2Add;
operator - :: Vector2Subtract;
operator * :: Vector2Scale #symmetric;

#scope_file

Math :: #import "Math";
