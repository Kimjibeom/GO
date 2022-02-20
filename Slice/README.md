# 슬라이스

- 슬라이스는 Go에서 제공하는 동적 배열 타입 (사이즈가 정해져 있지 않다.)

C++의 vector(int), Java의 ArrayList 등과 비슷한 느낌



# 슬라이스 구현은 배열을 가리키는 포인터와 요소 개수를 나타내는 len(length), 
# 전체 배열 길이를 나타내는 cap(capacity) 필드로 구성된 구조체


```
  type SliceHeader struct {
  
   Data uintptr            // 실제 배열을 가리키는 포인터
   
   Len int                 // 요소 개수
   
   Cap int                 // 실제 배열의 길이
   
  }
```

슬라이스가 실제 배열을 가리키는 포인터르 가지고 있어서 쉽게 크기가 다른 배열을 가리키도록 변경할 수 있고,

슬라이스 변수 대입 시 배열에 비해서 사용되느 메모리나 속도에 이점이 있습니다.

# 

# make() : 내장함수


```
var slice = make([]int,3)   // 여기서 3은 요소 개수

slice := []int{0,0,0}       // 위의 코드와 같은 결과
```


# append() : 슬라이스 요소 추가 (내장함수)

- 슬라이스에 요소를 추가한 슬라이스 반환


```
var slice = []int{1,2,3}    // 요소가 3개인 슬라이스

slice2 := append(slice, 4)  // 요소 추가

fmt.Println(slice)  // [ 1, 2, 3]

fmt.Println(sllice2)  //[ 1, 2, 3, 4]
```
