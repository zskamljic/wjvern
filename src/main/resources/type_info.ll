%java_TypeInfo = type { i32, i32*, i32, i32*, ptr }
%object_header = type { ptr, %java_TypeInfo* }

define i1 @instanceof(%object_header* %object, i32 %other) {
    ; If object ref is null, return zero
    %1 = icmp eq ptr %object, null
    br i1 %1, label %false, label %type_check
    ; TODO: add check for interfaces
type_check:
    ; Get the type info
    %2 = getelementptr inbounds %object_header, ptr %object, i32 0, i32 1
    %3 = load ptr, ptr %2
    ; Get number of types
    %4 = getelementptr inbounds %java_TypeInfo, %java_TypeInfo* %3, i32 0, i32 0
    %5 = load i32, ptr %4
    ; Get type array
    %6 = getelementptr inbounds %java_TypeInfo, %java_TypeInfo* %3, i32 0, i32 1
    %7 = load i32*, ptr %6
    ; Iterate type array
    %8 = alloca i32
    store i32 0, i32* %8
    br label %condition
condition:
    %9 = load i32, i32* %8
    %10 = icmp slt i32 %9, %5
    br i1 %10, label %next, label %false
next:
    %11 = getelementptr inbounds i32, ptr %7, i32 %9
    %12 = load i32, i32* %11
    %13 = icmp eq i32 %12, %other
    br i1 %13, label %true, label %increment
increment:
    %14 = add i32 %9, 1
    store i32 %14, i32* %8
    br label %condition
false:
    ret i1 0
true:
    ret i1 1
}

define ptr @type_interface_vtable(%object_header* %object, i32 %other) {
    ; Get the type info
    %1 = getelementptr inbounds %object_header, ptr %object, i32 0, i32 1
    %2 = load ptr, i32* %1
    ; Get number of interfaces
    %3 = getelementptr inbounds %java_TypeInfo, %java_TypeInfo* %2, i32 0, i32 2
    %4 = load i32, ptr %3
    ; Get interface id array
    %5 = getelementptr inbounds %java_TypeInfo, %java_TypeInfo* %2, i32 0, i32 3
    %6 = load i32*, ptr %5
    ; Get Interface vtable array
    %7 = getelementptr inbounds %java_TypeInfo, %java_TypeInfo* %2, i32 0, i32 4
    %8 = load ptr, ptr %7
    ; Iterate type array
    %9 = alloca i32
    store i32 0, i32* %9
    br label %condition
condition:
    %10 = load i32, i32* %9
    %11 = icmp slt i32 %10, %4
    br i1 %11, label %next, label %null
next:
    %12 = getelementptr inbounds i32, ptr %6, i32 %10
    %13 = load i32, i32* %12
    %14 = icmp eq i32 %13, %other
    br i1 %14, label %found, label %increment
increment:
    %15 = add i32 %10, 1
    store i32 %15, i32* %9
    br label %condition
null:
    ret ptr null
found:
    %16 = getelementptr inbounds i32, ptr %8, i32 %10
    %17 = load ptr, ptr %16
    ret ptr %17
}