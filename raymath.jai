#placeholder Vector2; // ensure raylib has provided Vector2

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

operator * :: (a: Vector2, k: float) -> Vector2  #symmetric {
    r: Vector2 = ---;
    r.x = a.x * k;
    r.y = a.y * k;

    return r;
}    


#scope_file

Math :: #import "Math";
