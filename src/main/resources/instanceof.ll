%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%object_header = type { ptr, %java_TypeInfo* }

define i1 @instanceof(%object_header* %object, i32 %other) {
    ; If object ref is null, return zero
    %1 = ptrtoint %object_header* %object to i32
    %2 = icmp eq i32 %1, 0
    br i1 %2, label %false, label %type_check
    ; TODO: add check for interfaces
type_check:
    ; Get the type info
    %3 = getelementptr inbounds %object_header, ptr %object, i32 0, i32 1
    %4 = load ptr, ptr %3
    ; Get number of types
    %5 = getelementptr inbounds %java_TypeInfo, %java_TypeInfo* %4, i32 0, i32 0
    %6 = load i32, ptr %4
    ; Get type array
    %7 = getelementptr inbounds %java_TypeInfo, %java_TypeInfo* %4, i32 0, i32 1
    %8 = load i32*, ptr %7
    ; Iterate type array
    %9 = alloca i32
    store i32 0, i32* %9
    br label %condition
condition:
    %10 = load i32, i32* %9
    %11 = icmp slt i32 %10, %6
    br i1 %11, label %next, label %false
next:
    %12 = getelementptr inbounds i32, ptr %8, i32 %10
    %13 = load i32, i32* %12
    %14 = icmp eq i32 %13, %other
    br i1 %14, label %true, label %increment
increment:
    %15 = add i32 %10, 1
    store i32 %15, i32* %9
    br label %condition
false:
    ret i1 0
true:
    ret i1 1
}