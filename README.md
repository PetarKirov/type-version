Sample output for:

```D
struct Color1 { union { uint value; struct { ubyte r, g, b, a; } } }
struct Color2 { union { float[3] atIndex; struct { float r, g, b; } } }
struct Color3 { union U1 { uint value; struct { ubyte r, g, b, a; } } U1 u; }
struct Color4 { union U2 { float[3] atIndex; struct { float r, g, b; } } U2 u; }
struct Point { float x, y, z; }
struct Triangle { Point a, b, c; }
class Model
{
    Triangle[] mesh;
    Color1[10] palette;
    Color2[10] palette2;
    Color3[10] palette3;
    Color4[10] palette4;
}

auto info = AggregateInfo!Model.init;
string s = aggregateInfoToJsonString!info;
```

can be found here: http://codebeautify.org/jsonviewer/cb8a3a7f
