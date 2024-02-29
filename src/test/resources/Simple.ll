%"java/lang/Object" = type { }

define void @"java/lang/Object_<init>"(ptr %this) {
  ret void
}

%Simple_vtable_type = type {  }

%Simple = type { %Simple_vtable_type* }

@Simple_vtable_data = global %Simple_vtable_type {
}

define void @"Simple_<init>"(%Simple* %this) {
label0:
  ; Line 1
  call void @"java/lang/Object_<init>"(%"java/lang/Object"* %this)
  ret void
}

define i32 @main() {
  ; Line 3
  ret i32 0
}
