%"java/lang/Object" = type { ptr }
%"java/lang/String" = type { ptr, %java_Array*, i8, i32, i1 }
%java_Array = type { i32, ptr }
%IfStatements = type { %IfStatements_vtable_type*, i32, i1 }
declare void @"java/lang/Object_<init>()V"(%"java/lang/Object"*)

declare i32 @"java/lang/Object_hashCode()I"(%"java/lang/Object"*) nounwind
declare i1 @"java/lang/Object_equals(Ljava/lang/Object;)Z"(%"java/lang/Object"*, %"java/lang/Object")
declare void @"java/lang/Object_notify()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_notifyAll()V"(%"java/lang/Object"*) nounwind
declare void @"java/lang/Object_wait0(J)V"(%"java/lang/Object"*, i64) nounwind
declare void @"java/lang/Object_finalize()V"(%"java/lang/Object"*)

%"java/lang/Object_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }
%"java/lang/String_vtable_type" = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)*, i32(%"java/lang/String"*)*, i1(%"java/lang/String"*)*, %"java/lang/String"(%"java/lang/String"*)*, i8(%"java/lang/String"*)*, i1(%"java/lang/String"*)* }
%IfStatements_vtable_type = type { i32(%"java/lang/Object"*)*, i1(%"java/lang/Object"*, %"java/lang/Object")*, void(%"java/lang/Object"*)* }

%"java/util/stream/IntStream" = type opaque
%"java/util/function/BiFunction" = type opaque
declare i32 @__gxx_personality_v0(...)
declare void @llvm.memset.p0.i8(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i16(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i32(ptr,i8,i64,i1)
declare void @llvm.memset.p0.i64(ptr,i8,i64,i1)

@IfStatements_vtable_data = global %IfStatements_vtable_type {
  i32(%"java/lang/Object"*)* @"java/lang/Object_hashCode()I",
  i1(%"java/lang/Object"*, %"java/lang/Object")* @"java/lang/Object_equals(Ljava/lang/Object;)Z",
  void(%"java/lang/Object"*)* @"java/lang/Object_finalize()V"
}

define void @"IfStatements_<init>()V"(%IfStatements* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 1
  call void @"java/lang/Object_<init>()V"(%"java/lang/Object"* %local.0)
  %0 = getelementptr inbounds %IfStatements, %IfStatements* %local.0, i32 0, i32 0
  store %IfStatements_vtable_type* @IfStatements_vtable_data, %IfStatements_vtable_type** %0
  ; Line 3
  %1 = getelementptr inbounds %IfStatements, %IfStatements* %local.0, i32 0, i32 2
  store i1 0, i1* %1
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define void @"IfStatements_doSomething()V"(%IfStatements* %local.0) personality ptr @__gxx_personality_v0 {
label0:
  ; %this entered scope under name %local.0
  ; Line 6
  %0 = getelementptr inbounds %IfStatements, %IfStatements* %local.0, i32 0, i32 2
  %1 = load i1, i1* %0
  %2 = sext i1 %1 to i32
  %3 = icmp ne i32 %2, 0
  br i1 %3, label %label2, label %label3
label3:
  ; Line 7
  %4 = getelementptr inbounds %IfStatements, %IfStatements* %local.0, i32 0, i32 2
  store i1 1, i1* %4
  ; Line 8
  %5 = getelementptr inbounds %IfStatements, %IfStatements* %local.0, i32 0, i32 1
  store i32 1, i32* %5
  br label %label4
label2:
  ; Line 10
  %6 = getelementptr inbounds %IfStatements, %IfStatements* %local.0, i32 0, i32 1
  store i32 2, i32* %6
  br label %label4
label4:
  ; Line 12
  ret void
label1:
  ; %this exited scope under name %local.0
  unreachable
}

define i32 @"IfStatements_main()I"() personality ptr @__gxx_personality_v0 {
  ; Line 15
  %1 = alloca %IfStatements
  call void @"IfStatements_<init>()V"(%IfStatements* %1)
  %local.0 = alloca ptr
  store %IfStatements* %1, ptr %local.0
  br label %label0
label0:
  ; %instance entered scope under name %local.0
  ; Line 16
  %2 = load %IfStatements*, %IfStatements** %local.0
  call void @"IfStatements_doSomething()V"(%IfStatements* %2)
  ; Line 17
  %3 = alloca %java_Array
  %4 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 0
  store i32 6, i32* %4
  %5 = alloca i8, i32 6
  %6 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  store ptr %5, ptr %6
  call void @llvm.memset.p0.i8(ptr %5, i8 0, i64 6, i1 false)
  %7 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %8 = load ptr, ptr %7
  %9 = getelementptr inbounds i8, ptr %8, i32 0
  store i8 106, ptr %9
  %10 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %11 = load ptr, ptr %10
  %12 = getelementptr inbounds i8, ptr %11, i32 1
  store i8 58, ptr %12
  %13 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %14 = load ptr, ptr %13
  %15 = getelementptr inbounds i8, ptr %14, i32 2
  store i8 37, ptr %15
  %16 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %17 = load ptr, ptr %16
  %18 = getelementptr inbounds i8, ptr %17, i32 3
  store i8 100, ptr %18
  %19 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %20 = load ptr, ptr %19
  %21 = getelementptr inbounds i8, ptr %20, i32 4
  store i8 10, ptr %21
  %22 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %23 = load ptr, ptr %22
  %24 = getelementptr inbounds i8, ptr %23, i32 5
  store i8 0, ptr %24
  %25 = alloca %java_Array
  %26 = getelementptr inbounds %java_Array, %java_Array* %25, i32 0, i32 0
  store i32 1, i32* %26
  %27 = alloca i32, i32 1
  %28 = getelementptr inbounds %java_Array, %java_Array* %25, i32 0, i32 1
  store ptr %27, ptr %28
  call void @llvm.memset.p0.i32(ptr %27, i8 0, i64 4, i1 false)
  %29 = load %IfStatements*, %IfStatements** %local.0
  %30 = getelementptr inbounds %IfStatements, %IfStatements* %29, i32 0, i32 1
  %31 = load i32, i32* %30
  %32 = getelementptr inbounds %java_Array, %java_Array* %25, i32 0, i32 1
  %33 = load ptr, ptr %32
  %34 = getelementptr inbounds i32, ptr %33, i32 0
  store i32 %31, ptr %34
  %35 = getelementptr inbounds %java_Array, ptr %25, i32 0, i32 1
  %36 = load ptr, ptr %35
  %37 = getelementptr inbounds %java_Array, ptr %36, i32 0
  %38 = load i32, i32* %37
  %39 = getelementptr inbounds %java_Array, %java_Array* %3, i32 0, i32 1
  %40 = load ptr, ptr %39
  %41 = call i32(i8*,...) @printf(i8* %40, i32 %38)
  ; Line 18
  %42 = load %IfStatements*, %IfStatements** %local.0
  call void @"IfStatements_doSomething()V"(%IfStatements* %42)
  ; Line 19
  %43 = alloca %java_Array
  %44 = getelementptr inbounds %java_Array, %java_Array* %43, i32 0, i32 0
  store i32 6, i32* %44
  %45 = alloca i8, i32 6
  %46 = getelementptr inbounds %java_Array, %java_Array* %43, i32 0, i32 1
  store ptr %45, ptr %46
  call void @llvm.memset.p0.i8(ptr %45, i8 0, i64 6, i1 false)
  %47 = getelementptr inbounds %java_Array, %java_Array* %43, i32 0, i32 1
  %48 = load ptr, ptr %47
  %49 = getelementptr inbounds i8, ptr %48, i32 0
  store i8 106, ptr %49
  %50 = getelementptr inbounds %java_Array, %java_Array* %43, i32 0, i32 1
  %51 = load ptr, ptr %50
  %52 = getelementptr inbounds i8, ptr %51, i32 1
  store i8 58, ptr %52
  %53 = getelementptr inbounds %java_Array, %java_Array* %43, i32 0, i32 1
  %54 = load ptr, ptr %53
  %55 = getelementptr inbounds i8, ptr %54, i32 2
  store i8 37, ptr %55
  %56 = getelementptr inbounds %java_Array, %java_Array* %43, i32 0, i32 1
  %57 = load ptr, ptr %56
  %58 = getelementptr inbounds i8, ptr %57, i32 3
  store i8 100, ptr %58
  %59 = getelementptr inbounds %java_Array, %java_Array* %43, i32 0, i32 1
  %60 = load ptr, ptr %59
  %61 = getelementptr inbounds i8, ptr %60, i32 4
  store i8 10, ptr %61
  %62 = getelementptr inbounds %java_Array, %java_Array* %43, i32 0, i32 1
  %63 = load ptr, ptr %62
  %64 = getelementptr inbounds i8, ptr %63, i32 5
  store i8 0, ptr %64
  %65 = alloca %java_Array
  %66 = getelementptr inbounds %java_Array, %java_Array* %65, i32 0, i32 0
  store i32 1, i32* %66
  %67 = alloca i32, i32 1
  %68 = getelementptr inbounds %java_Array, %java_Array* %65, i32 0, i32 1
  store ptr %67, ptr %68
  call void @llvm.memset.p0.i32(ptr %67, i8 0, i64 4, i1 false)
  %69 = load %IfStatements*, %IfStatements** %local.0
  %70 = getelementptr inbounds %IfStatements, %IfStatements* %69, i32 0, i32 1
  %71 = load i32, i32* %70
  %72 = getelementptr inbounds %java_Array, %java_Array* %65, i32 0, i32 1
  %73 = load ptr, ptr %72
  %74 = getelementptr inbounds i32, ptr %73, i32 0
  store i32 %71, ptr %74
  %75 = getelementptr inbounds %java_Array, ptr %65, i32 0, i32 1
  %76 = load ptr, ptr %75
  %77 = getelementptr inbounds %java_Array, ptr %76, i32 0
  %78 = load i32, i32* %77
  %79 = getelementptr inbounds %java_Array, %java_Array* %43, i32 0, i32 1
  %80 = load ptr, ptr %79
  %81 = call i32(i8*,...) @printf(i8* %80, i32 %78)
  ; Line 20
  ret i32 0
label1:
  ; %instance exited scope under name %local.0
  unreachable
}

declare i32 @printf(%java_Array, ...) nounwind
