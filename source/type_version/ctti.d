/// Contains templates for compile-time type information
module type_version.ctti;

enum Kind { module_, class_, struct_, union_, enum_, function_, staticArray_, dynamicArray_, primitive_ }

template KindOf(T)
{
    import std.traits : isBasicType;

    static if (is(T == class))
        enum Kind KindOf = Kind.class_;

    else static if (is(T == struct))
        enum Kind KindOf = Kind.struct_;

    else static if (is(T == union))
        enum Kind KindOf = Kind.union_;

    else static if (is(T == enum))
        enum Kind KindOf = Kind.enum_;

    else static if (is(T == function) ||
            is(T == RT function(Args), RT, Args...) ||
            is(T == RT delegate(Args), RT, Args...))
        enum Kind KindOf = Kind.function_;

    else static if (is(T == E[n], E, size_t n))
        enum Kind KindOf = Kind.staticArray_;

    else static if (is(T == E[], E))
        enum Kind KindOf = Kind.dynamicArray_;

    else static if (isBasicType!T)
        enum Kind KindOf = Kind.primitive_;

    else
        static assert (0, "Error: Unsupported template argument: " ~ T.stringof);
}

unittest
{
    class C {}
    struct S {}
    union U {}
    enum Eempty;
    enum Eone { a }
    enum Ebool : bool { a }
    void delg() {}
    static void func() {}
    alias SSArr = S[10];
    alias SDArr = S[];

    static assert (KindOf!C      == Kind.class_);
    static assert (KindOf!S      == Kind.struct_);
    static assert (KindOf!U      == Kind.union_);
    static assert (KindOf!Eempty == Kind.enum_);
    static assert (KindOf!Eone   == Kind.enum_);
    static assert (KindOf!Ebool  == Kind.enum_);
    static assert (KindOf!(typeof(func))  == Kind.function_);
    static assert (KindOf!(typeof(&func)) == Kind.function_);
    static assert (KindOf!(typeof(delg))  == Kind.function_);
    static assert (KindOf!(typeof(&delg)) == Kind.function_);
    static assert (KindOf!SSArr  == Kind.staticArray_);
    static assert (KindOf!SDArr  == Kind.dynamicArray_);
}

struct MemberVariable(T, size_t idx)
{
    enum string name = T.tupleof[idx].stringof;
    alias type = AggregateInfo!(typeof(T.tupleof[idx]));
    enum size_t offset = T.tupleof[idx].offsetof;
}

///
struct AggregateInfo(T)
{
    enum string name = T.stringof;
    enum size_t size = T.sizeof;
    enum Kind kind = KindOf!T;

    static if (kind == Kind.class_ || kind == Kind.struct_ || kind == Kind.union_)
    {
        import std.meta : staticMap, ApplyLeft;
        import std.typecons : staticIota;
        import std.traits : Fields;
        alias memberVaraibles = staticMap!(ApplyLeft!(MemberVariable, T), staticIota!(0, Fields!T.length));
    }
    else static if (kind == Kind.enum_)
    {
        import std.traits : EnumMebers;
        alias memberVaraibles = void;

        static if (EnumMebers!T.length == 0)
        {
            alias elementType = void;
        }
        else
        {
            import std.meta : AliasSeq;
            import std.traits : OriginalType;
            alias elementType = AliasSeq!(AggregateInfo!(OriginalType!T));
        }
    }
    else static if (kind == Kind.staticArray_ || kind == Kind.dynamicArray_)
    {
        import std.meta : AliasSeq;
        import std.range.primitives : ElementEncodingType;
        alias memberVaraibles = void;
        alias elementType = AggregateInfo!(ElementEncodingType!T);
    }
    else
    {
        alias memberVaraibles = void;
        alias elementType = void;
    }


}

string aggregateInfoToJsonString(alias info)(uint indentLevel = 0)
{
    import std.format : format;
    import std.conv : to;

    string ind1, ind2, ind3, ind4;

    foreach (_; 0 .. (indentLevel + 0) * 2) ind1 ~= " ";
    foreach (_; 0 .. (indentLevel + 1) * 2) ind2 ~= " ";
    foreach (_; 0 .. (indentLevel + 2) * 2) ind3 ~= " ";
    foreach (_; 0 .. (indentLevel + 3) * 2) ind4 ~= " ";

    string result = format("%1$s{\n%2$s\"name\" : \"%3$s\",\n%2$s\"size\" : \"%4$s\",\n%2$s\"kind\" : \"%5$s\",\n%2$s\"members\" :\n",
        ind1, ind2, info.name, info.size, info.kind.to!string[0 .. $-1]);

    static if (!is(info.memberVaraibles == void))
    {
        result ~= ind2 ~ "[\n";

        foreach (idx, member; info.memberVaraibles)
        {
            enum lastIdx = idx == info.memberVaraibles.length - 1;

            result ~= "%1$s{\n%2$s\"name\" : \"%3$s\",\n%2$s\"offset\": \"%5$s\",\n%2$s\"type\" :\n%4$s%1$s}"
                .format(ind3, ind4, member.name, aggregateInfoToJsonString!(member.type)(indentLevel + 3), member.offset);

            result ~= lastIdx? "\n" : ",\n";
        }

        result ~= ind2 ~ "]\n";
    }
    else static if (!is(info.elementType == void))
    {
        result ~= aggregateInfoToJsonString!(info.elementType)(indentLevel + 2);
    }
    else
        result ~= ind2 ~ "[ ]\n";

    result ~= ind1 ~ "}\n";

    return result;
}

///
unittest
{
}
