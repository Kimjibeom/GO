# Makefile 조건문



### Makefile 조건문의 지시어

* ifeq : 조건을 시작하고 조건을 지정한다. 콤마로 분리되고 괄호로 둘러싸인 두 개의 매개변수를 가진다.
* else : 이전 조건이 실패했다면 수행되도록 한다. else 지시어는 사용하지 않아도 된다.
* endif : 조건을 종료한다. 모든 조건은 반드시 endif로 종룔해야 한다.

### Makefile 조건문 예시

```
libs_for_gcc = -lgnu 
normal_libs = 

foo: $(objects) 
ifeq ($(CC),gcc)  // 변수 'CC'가 'gcc'일 때 실행
      $(CC) -o foo $(objects) $(libs_for_gcc) 
else              // 변수 'CC'가 'gcc'아닐 때 실행
      $(CC) -o foo $(objects) $(normal_libs) 
endif
```

### Makefile 다중 조건문(중첩 조건)

* 기본적으로, make에서 다중 조건문은 존재하지 않는다.
* AND(&&) 또는 OR(||)를 사용할 수 없다.
