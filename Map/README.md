# 맵

- 맵은 키(Key)에 대응하는 값(Value)을 신속히 찾는 해시테이블(Hash table)을 구현한 자료구조
- 언어에 따라서 딕셔너리(dictionary), 해시테이블(hash table), 해시맵(hash map)등으로 부른다.

Go 언어는 Map 타입을 내장하고 있는데, "map[Key타입]Value타입" 과 같이 선언한다.

```
var idMap map[int]string
```

이때 선언된 변수 idMap은 (map은 reference 타입이므로) nil 값을 갖으며, 이를 Nil Map이라 부른다.

Nil Map에는 어떤 데이터를 쓸 수 없는데, map을 초기화하기 위해 make()함수를 사용한다.

(map 리터럴을 사용할수도 있는데 이는 아래 참조.)

```
idMap = make(map[int]string)
```

make()함수의 첫번째 파라미터로 map 키워드와 [키타입]값타입을 지정하는데,

이때의 make()함수는 해시테이블 자료구조를 메모리에 생성하고 그 메모리를 가리키는 map value를 리턴한다.

(map value는 내부적으로 runtime.hmap 구조체를 가리키는 포인터이다.)

따라서 idMap 변수는 이 해시테이블을 가리키는 map을 가리키게 된다.

map은 make()함수 말고 리터럴(literal)을 사용해 초기화할수도 있다.

리터럴 초기화는 "map[Key타입]Value타입 {key:value}" 와 같이 Map 타입 뒤 {} 괄호 안에 "키:값" 들을 열거하면 된다.

```
// 리터럴을 사용한 초기화
tickers := map[string]string{
  "GOOG": "Google Inc",
  "MSFT": "Microsoft",
  "FB": "FaceBook",
}
```


