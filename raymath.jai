#import "Math";

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
    return sqrt((v.x*v.x) + (v.y*v.y));
}