package main

import "fmt"

func main() {
	m := make(map[string]string) // 맵 생성
	m["이화랑"] = "서울시 광진구"
	m["송하나"] = "서울시 강남구" // 키와 값 추가
	m["백두산"] = "부산시 사하구"
	m["김지범"] = "전주시 완산구"

	m["김지범"] = "세종시 조치원읍" // 값 변경

	fmt.Printf("송하나의 주소는 %s입니다.\n", m["송하나"]) // 값 출력
	fmt.Printf("김지범의 주소는 %s입니다.\n", m["김지범"])
}
