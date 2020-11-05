Vector2Add :: (v1: rl.Vector2, v2: rl.Vector2) -> rl.Vector2
{
    return rl.make_Vector2(v1.x + v2.x, v1.y + v2.y);
}

Vector2Subtract :: (v1: rl.Vector2, v2: rl.Vector2) -> rl.Vector2
{
    return rl.make_Vector2(v1.x - v2.x, v1.y - v2.y);
}

Vector2Scale :: (v: rl.Vector2, scale: float) -> rl.Vector2
{
    return rl.make_Vector2(v.x*scale, v.y*scale);
}

Vector2Scale :: (a: rl.Vector2, b: rl.Vector2) -> rl.Vector2 {
    return rl.make_Vector2(a.x * b.x, a.y * b.y);
}

Vector2Length :: (v: rl.Vector2) -> float
{
    return Math.sqrt((v.x*v.x) + (v.y*v.y));
}

Vector2Normalize :: (v: rl.Vector2) -> rl.Vector2 {
    return Vector2Scale(v, 1/Vector2Length(v));
}

operator + :: (a: rl.Vector2, b: rl.Vector2) -> rl.Vector2 {
    r: rl.Vector2 = ---;

    r.x = a.x + b.x;
    r.y = a.y + b.y;

    return r;
}

operator - :: (a: rl.Vector2, b: rl.Vector2) -> rl.Vector2 {
    r: rl.Vector2 = ---;
    r.x = a.x - b.x;
    r.y = a.y - b.y;
    return r;
}

operator - :: (a: rl.Vector3, b: rl.Vector3) -> rl.Vector3 {
    r: rl.Vector3 = ---;
    r.x = a.x - b.x;
    r.y = a.y - b.y;
    r.z = a.z - b.z;
    return r;
}

operator + :: (a: rl.Vector2, b: s64) -> rl.Vector2 {
    r: rl.Vector2 = ---;
    r.x = a.x + cast(float)b;
    r.y = a.y + cast(float)b;
    return r;
}

operator + :: (a: rl.Vector3, b: rl.Vector3) -> rl.Vector3 {
    r: rl.Vector3 = ---;
    r.x = a.x + b.x;
    r.y = a.y + b.y;
    r.z = a.z + b.z;
    return r;
}


operator - :: (a: rl.Vector2, b: s64) -> rl.Vector2 {
    r: rl.Vector2 = ---;
    r.x = a.x - cast(float)b;
    r.y = a.y - cast(float)b;
    return r;
}

operator * :: (a: rl.Vector2, k: float) -> rl.Vector2  #symmetric {
    r: rl.Vector2 = ---;
    r.x = a.x * k;
    r.y = a.y * k;

    return r;
}    

operator * :: (a: rl.Vector3, k: float) -> rl.Vector3 {
    r: rl.Vector3 = ---;
    r.x = a.x * k;
    r.y = a.y * k;
    r.z = a.z * k;
    return r;
}

operator == :: (v1: rl.Vector2, v2: rl.Vector2) -> bool { return v1.x == v2.x && v1.y == v2.y; }
operator != :: (v1: rl.Vector2, v2: rl.Vector2) -> bool { return v1.x != v2.x || v1.y != v2.y; }

normalized :: (using v: rl.Vector3, epsilon := 0, fallback := rl.Vector3.{}) -> rl.Vector3 {
    sq := Math.sqrt(x*x + y*y + z*z);
    if sq == 0 return fallback;

    factor := 1.0 / sq;
    x *= factor;
    y *= factor;
    z *= factor;

    return v;
}


#scope_file
Math :: #import "Math";
rl :: #import "raylib";

