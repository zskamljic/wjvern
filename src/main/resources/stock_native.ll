%"java/lang/Object" = type opaque

define i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"* %this) nounwind {
    %1 = ptrtoint ptr %this to i32
    ret i32 %1
}

define void @"java/lang/String_intern()Ljava/lang/String;"() {
    ret void
}

%java_Array = type { i32, ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }

; TODO: remove below when compilation of these is supported

define void @"java/lang/String_getBytes()[B"(ptr sret(%java_Array*) %local.0, %"java/lang/String"* %this) {
    %1 = getelementptr inbounds %"java/lang/String", %"java/lang/String"* %this, i32 0, i32 1
    %2 = load %java_Array*, ptr %1
    %3 = load %java_Array, %java_Array* %2
    store %java_Array %3, %java_Array* %local.0
    ret void
}

define i8 @"java/lang/String_coder()B"(%"java/lang/String"* %this) {
    ret i8 0
}