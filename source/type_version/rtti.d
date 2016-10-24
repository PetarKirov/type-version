///
module type_version.rtti;

struct TypeInfo
{
    string TypeName;
    MemberInfo[] members;
    //MethodInfo[] methods;
}

struct FunctionInfo
{
    TypeInfo returnType;
    TypeInfo[] aA;
}

struct MethodInfo
{
    TypeInfo returnType;
    TypeInfo[] parameters;
}

struct MemberInfo
{
    TypeInfo type;
    uint offset;
}
