%3 = sub i32 %0, 1
%4 = alloca %java_Array
%5 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 0
store i32 %3, i32* %5
%6 = alloca %"java/lang/String", i32 %3
%7 = getelementptr inbounds %java_Array, %java_Array* %4, i32 0, i32 1
store ptr %6, ptr %7

%8 = alloca i32
store i32 0, i32* %8
br label %condition

condition:
%9 = load i32, i32* %8
%10 = icmp slt i32 %9, %3
br i1 %10, label %next, label %end

next:
%11 = add i32 %9, 1
%12 = getelementptr inbounds ptr, ptr %1, i32 %11
%13 = load ptr, ptr %12
%14 = call i64 @strlen(ptr %13)
%15 = trunc i64 %14 to i32
%16 = alloca %java_Array
%17 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 0
store i32 %15, i32* %17
%18 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 1
store ptr %13, ptr %18
%19 = alloca %"java/lang/String"
call void @"java/lang/String_<init>([BB)V"(%"java/lang/String"* %19, %java_Array* %16, i8 0)
%20 = getelementptr inbounds %"java/lang/String", ptr %6, i32 %9
store %"java/lang/String"* %19, ptr %20
br label %increment

increment:
%21 = add nsw i32 %9, 1
store i32 %21, i32* %8
br label %condition

end: