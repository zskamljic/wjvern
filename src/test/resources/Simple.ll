%"java/lang/Object" = type { }

define void @"java/lang/Object_<init>"(ptr %this) {
  ret void
}

%Simple = type { }

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
