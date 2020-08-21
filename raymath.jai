#import "raylib";

Vector2Add :: (v1: Vector2, v2: Vector2) -> Vector2
{
    return make_Vector2(v1.x + v2.x, v1.y + v2.y);
}

Vector2Subtract :: (v1: Vector2, v2: Vector2) -> Vector2
{
    return make_Vector2(v1.x - v2.x, v1.y - v2.y);
}

Vector2Scale :: (v: Vector2, scale: float) -> Vector2
{
    return make_Vector2(v.x*scale, v.y*scale);
}

Vector2Length :: (v: Vector2) -> float
{
    return Math.sqrt((v.x*v.x) + (v.y*v.y));
}

Vector2Normalize :: (v: Vector2) -> Vector2 {
    return Vector2Scale(v, 1/Vector2Length(v));
}

operator + :: (a: Vector2, b: Vector2) -> Vector2 {
    r: Vector2 = ---;

    r.x = a.x + b.x;
    r.y = a.y + b.y;

    return r;
}

operator - :: (a: Vector2, b: Vector2) -> Vector2 {
    r: Vector2 = ---;
    r.x = a.x - b.x;
    r.y = a.y - b.y;
    return r;
}

operator + :: (a: Vector2, b: s64) -> Vector2 {
    r: Vector2 = ---;
    r.x = a.x + cast(float)b;
    r.y = a.y + cast(float)b;
    return r;
}

operator - :: (a: Vector2, b: s64) -> Vector2 {
    r: Vector2 = ---;
    r.x = a.x - cast(float)b;
    r.y = a.y - cast(float)b;
    return r;
}

operator * :: (a: Vector2, k: float) -> Vector2  #symmetric {
    r: Vector2 = ---;
    r.x = a.x * k;
    r.y = a.y * k;

    return r;
}    

operator == :: (v1: Vector2, v2: Vector2) -> bool { return v1.x == v2.x && v1.y == v2.y; }
operator != :: (v1: Vector2, v2: Vector2) -> bool { return v1.x != v2.x || v1.y != v2.y; }


#scope_file

Math :: #import "Math";
