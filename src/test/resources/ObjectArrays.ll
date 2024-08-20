%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%ObjectArrays = type { %ObjectArrays_vtable_type*, i32 }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%ObjectArrays_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@ObjectArrays_vtable_data = global %ObjectArrays_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"ObjectArrays_<init>(I)V"(%ObjectArrays* %local.0, i32 %local.1) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; %x entered scope under name %local.1
  ; Line 4
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %ObjectArrays, %ObjectArrays* %local.0, i32 0, i32 0
  store %ObjectArrays_vtable_type* @ObjectArrays_vtable_data, %ObjectArrays_vtable_type** %0
  ; Line 5
  %1 = getelementptr inbounds %ObjectArrays, %ObjectArrays* %local.0, i32 0, i32 1
  store i32 %local.1, i32* %1
  ; Line 6
  ret void
label1:
  ; %this exited scope under name %local.0
  ; %x exited scope under name %local.1
  unreachable
}

define i32 @main() personality ptr @__gxx_personality_v0 {
  ; Line 9
  %1 = alloca %java_Array
  %2 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 0
  store i32 3, i32* %2
  %3 = alloca i32, i32 3
  %4 = getelementptr inbounds %java_Array, %java_Array* %1, i32 0, i32 1
  store ptr %3, ptr %4
  call void @llvm.memset.p0.i32(ptr %3, i8 0, i64 12, i1 false)
  %local.0 = alloca ptr
  store %java_Array* %1, ptr %local.0
  br label %label8
label8:
  ; %intArray entered scope under name %local.0
  ; Line 11
  %local.1 = alloca ptr
  store i32 0, ptr %local.1
  br label %label0
label0:
  ; %i entered scope under name %local.1
  %5 = load %java_Array*, %java_Array** %local.0
  %6 = getelementptr inbounds %java_Array, %java_Array* %5, i32 0, i32 0
  %7 = load i32, ptr %6
  %8 = load i32, i32* %local.1
  %9 = icmp sge i32 %8, %7
  br i1 %9, label %label1, label %label11
label11:
  ; Line 12
  %10 = load %java_Array*, %java_Array** %local.0
  %11 = getelementptr inbounds %java_Array, %java_Array* %10, i32 0, i32 1
  %12 = load ptr, ptr %11
  %13 = load i32, i32* %local.1
  %14 = getelementptr inbounds i32, ptr %12, i32 %13
  %15 = load i32, i32* %local.1
  store i32 %15, ptr %14
  ; Line 11
  %16 = load i32, i32* %local.1
  %17 = add i32 %16, 1
  store i32 %17, i32* %local.1
  br label %label0
label1:
  ; %i exited scope under name %local.1
  ; Line 15
  store i32 0, ptr %local.1
  br label %label2
label2:
  ; %j entered scope under name %local.1
  %18 = load %java_Array*, %java_Array** %local.0
  %19 = getelementptr inbounds %java_Array, %java_Array* %18, i32 0, i32 0
  %20 = load i32, ptr %19
  %21 = load i32, i32* %local.1
  %22 = icmp sge i32 %21, %20
  br i1 %22, label %label3, label %label12
label12:
  ; Line 16
  %23 = load %java_Array*, %java_Array** %local.0
  %24 = load i32, i32* %local.1
  %25 = getelementptr inbounds %java_Array, %java_Array* %23, i32 0, i32 1
  %26 = load ptr, ptr %25
  %27 = getelementptr inbounds i32, ptr %26, i32 %24
  %28 = load i32, ptr %27
  call void @print(i32 %28)
  ; Line 15
  %29 = load i32, i32* %local.1
  %30 = add i32 %29, 1
  store i32 %30, i32* %local.1
  br label %label2
label3:
  ; %j exited scope under name %local.1
  ; Line 19
  %31 = alloca %java_Array
  %32 = getelementptr inbounds %java_Array, %java_Array* %31, i32 0, i32 0
  store i32 3, i32* %32
  %33 = alloca %ObjectArrays, i32 3
  %34 = getelementptr inbounds %java_Array, %java_Array* %31, i32 0, i32 1
  store ptr %33, ptr %34
  store %java_Array* %31, ptr %local.1
  br label %label10
label10:
  ; %array entered scope under name %local.1
  ; Line 20
  %35 = load %java_Array*, %java_Array** %local.1
  %36 = getelementptr inbounds %java_Array, %java_Array* %35, i32 0, i32 0
  %37 = load i32, ptr %36
  call void @print(i32 %37)
  ; Line 22
  %local.2 = alloca ptr
  store i32 0, ptr %local.2
  br label %label4
label4:
  ; %k entered scope under name %local.2
  %38 = load %java_Array*, %java_Array** %local.1
  %39 = getelementptr inbounds %java_Array, %java_Array* %38, i32 0, i32 0
  %40 = load i32, ptr %39
  %41 = load i32, i32* %local.2
  %42 = icmp sge i32 %41, %40
  br i1 %42, label %label5, label %label13
label13:
  ; Line 23
  %43 = load %java_Array*, %java_Array** %local.1
  %44 = alloca %ObjectArrays
  %45 = load i32, i32* %local.2
  call void @"ObjectArrays_<init>(I)V"(%ObjectArrays* %44, i32 %45)
  %46 = getelementptr inbounds %java_Array, %java_Array* %43, i32 0, i32 1
  %47 = load ptr, ptr %46
  %48 = load i32, i32* %local.2
  %49 = getelementptr inbounds %ObjectArrays, ptr %47, i32 %48
  store %ObjectArrays* %44, ptr %49
  ; Line 22
  %50 = load i32, i32* %local.2
  %51 = add i32 %50, 1
  store i32 %51, i32* %local.2
  br label %label4
label5:
  ; %k exited scope under name %local.2
  ; Line 26
  store i32 0, ptr %local.2
  br label %label6
label6:
  ; %l entered scope under name %local.2
  %52 = load %java_Array*, %java_Array** %local.1
  %53 = getelementptr inbounds %java_Array, %java_Array* %52, i32 0, i32 0
  %54 = load i32, ptr %53
  %55 = load i32, i32* %local.2
  %56 = icmp sge i32 %55, %54
  br i1 %56, label %label7, label %label14
label14:
  ; Line 27
  %57 = load %java_Array*, %java_Array** %local.1
  %58 = load i32, i32* %local.2
  %59 = getelementptr inbounds %java_Array, %java_Array* %57, i32 0, i32 1
  %60 = load ptr, ptr %59
  %61 = getelementptr inbounds %ObjectArrays, ptr %60, i32 %58
  %62 = load %ObjectArrays*, ptr %61
  %63 = getelementptr inbounds %ObjectArrays, %ObjectArrays* %62, i32 0, i32 1
  %64 = load i32, i32* %63
  call void @print(i32 %64)
  ; Line 26
  %65 = load i32, i32* %local.2
  %66 = add i32 %65, 1
  store i32 %66, i32* %local.2
  br label %label6
label7:
  ; %l exited scope under name %local.2
  ; Line 29
  ret i32 0
label9:
  ; %intArray exited scope under name %local.0
  ; %array exited scope under name %local.1
  unreachable
}

define void @print(i32 %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %number entered scope under name %local.0
  ; Line 33
  %0 = alloca %java_Array
  %1 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 0
  store i32 4, i32* %1
  %2 = alloca i8, i32 4
  %3 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  store ptr %2, ptr %3
  call void @llvm.memset.p0.i8(ptr %2, i8 0, i64 4, i1 false)
  %4 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %5 = load ptr, ptr %4
  %6 = getelementptr inbounds i8, ptr %5, i32 0
  store i8 37, ptr %6
  %7 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %8 = load ptr, ptr %7
  %9 = getelementptr inbounds i8, ptr %8, i32 1
  store i8 100, ptr %9
  %10 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %11 = load ptr, ptr %10
  %12 = getelementptr inbounds i8, ptr %11, i32 2
  store i8 10, ptr %12
  %13 = getelementptr inbounds %java_Array, %java_Array* %0, i32 0, i32 1
  %14 = load ptr, ptr %13
  %15 = getelementptr inbounds i8, ptr %14, i32 3
  store i8 0, ptr %15
  %local.1 = alloca ptr
  store %java_Array* %0, ptr %local.1
  br label %label2
label2:
  ; %pattern entered scope under name %local.1
  ; Line 34
  %16 = load %java_Array*, %java_Array** %local.1
  %17 = alloca %java_Array
  %18 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 0
  store i32 1, i32* %18
  %19 = alloca i32, i32 1
  %20 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 1
  store ptr %19, ptr %20
  call void @llvm.memset.p0.i32(ptr %19, i8 0, i64 4, i1 false)
  %21 = getelementptr inbounds %java_Array, %java_Array* %17, i32 0, i32 1
  %22 = load ptr, ptr %21
  %23 = getelementptr inbounds i32, ptr %22, i32 0
  store i32 %local.0, ptr %23
  %24 = getelementptr inbounds %java_Array, ptr %17, i32 0, i32 1
  %25 = load ptr, ptr %24
  %26 = getelementptr inbounds %java_Array, ptr %25, i32 0
  %27 = load i32, i32* %26
  %28 = getelementptr inbounds %java_Array, %java_Array* %16, i32 0, i32 1
  %29 = load ptr, ptr %28
  %30 = call i32(i8*,...) @printf(i8* %29, i32 %27)
  ; Line 35
  ret void
label1:
  ; %number exited scope under name %local.0
  ; %pattern exited scope under name %local.1
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
