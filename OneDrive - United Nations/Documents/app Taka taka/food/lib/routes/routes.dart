enum Routes {
  splashScreen("/"),
  login("/login"),
  superPage("/home"),
  newPost("/post");

  final String path;

  const Routes(this.path);

}