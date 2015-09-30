System.config({
  baseURL: "/blog/lib/",
  defaultJSExtensions: true,
  transpiler: "none",
  paths: {
    "github:*": "../../output/blog/lib/jspm_packages/github/*",
    "npm:*": "../../output/blog/lib/jspm_packages/npm/*"
  }
});
