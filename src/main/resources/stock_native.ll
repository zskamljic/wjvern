%"java/lang/Object" = type opaque

define i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"* %this) nounwind {
    %1 = ptrtoint ptr %this to i32
    ret i32 %1
}