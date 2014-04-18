
dependencies = ['mini-test']

for moduleName in define.all()
  if moduleName && moduleName.substr(moduleName.length - 5, 5) == '-test'
    dependencies.push(moduleName)

require dependencies, (miniTest) -> miniTest.run()
