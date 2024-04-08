package main

import (
	"container/ring"
	"fmt"
)

func main() {
	r := ring.New(5) // 요소가 5개인 링 생성

	n := r.Len() // 링 개수 반환

	for i := 0; i < n; i++ {
		r.Value = 'A' + i // 순회하면 모든 요소에 값 대입
		r = r.Next()
	}

	for j := 0; j < n; j++ {
		fmt.Printf("%c ", r.Value) // 순회하며 값 출력
		r = r.Next()
	}

	fmt.Println() // 한줄 띄우기

	for j := 0; j < n; j++ {
		fmt.Printf("%c ", r.Value) // 순회하며 값 출력
		r = r.Prev()
	}
}
