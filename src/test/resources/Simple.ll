%"java/lang/Object" = type opaque

declare void @"java/lang/Object_<init>"(%"java/lang/Object"*)

%Simple_vtable_type = type { }

%Simple = type { %Simple_vtable_type* }

@Simple_vtable_data = global %Simple_vtable_type {
}

define void @"Simple_<init>"(%Simple* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  %0 = getelementptr inbounds %Simple, %Simple* %this, i64 0, i32 0
  store %Simple_vtable_type* @Simple_vtable_data, %Simple_vtable_type** %0
  ret void
}

define i32 @main() {
  ; Line 3
  ret i32 0
}
