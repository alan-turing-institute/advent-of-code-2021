Full disclaimer: First time using Scala.

- I installed Scala 3 following https://docs.scala-lang.org/scala3/getting-started.html
  ```
  brew install coursier/formulas/coursier && cs setup
  cs install scala3-compiler
  cs install scala3
  ```

- Added Coursier to my path in .zshrc:
  ```
  export PATH="$PATH:/Users/jroberts/Library/Application Support/Coursier/bin"
  ```

- Figured out some syntax with help of the [Scala 3 book](https://docs.scala-lang.org/scala3/book/introduction.html), a lot of Googling, and trial and error. 

- Compiled the code: `scala3-compiler Day1.scala`

- Ran the code: `scala3 day1`
