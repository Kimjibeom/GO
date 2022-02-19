# DeepCopy


깊은 복사(Deep Copy)는 해당 변수의 주소에 있는 값을 복사하는 것을 의미한다. 이 때의 복사한 객체는 새로운 주소값을 가지며 복사된 이후로 복사한 객체와 복사된 객체는 별개의 객체가 된다. 즉, 한 쪽의 객체를 변경해도 다른 쪽은 이미 별개의 객체이기 때문에 영향을 받지 않게 된다. 깊은 복사는 언어 차원에서 지원하지 않기 때문에 메소드로 직접 구현해야 한다.