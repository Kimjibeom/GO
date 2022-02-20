package main

type Blog struct {
	id   int
	name string
	url  string
}

func main() {
	// Case 1
	var blog Blog
	blog.id = 1
	blog.name = "Kimjibeom"
	blog.url = "https://github.com/Kimjibeom/GO"

	// Case 2
	blog = Blog{id: 1, name: "Kimjibeom", url: "https://github.com/Kimjibeom/GO"}

	// Case 3
	blog = Blog{1, "Kimjibeom", "https://github.com/Kimjibeom/GO"}
}
