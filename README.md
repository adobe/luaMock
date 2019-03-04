Testing Framework for Lua - Mocka [![Build Status](https://travis-ci.org/adobe/mocka.svg?branch=master)](https://travis-ci.org/adobe/mocka) 
[![Coverage Status](https://coveralls.io/repos/github/adobe/mocka/badge.svg?branch=HEAD)](https://coveralls.io/github/adobe/mocka?branch=HEAD) 
------

The one lua testing framework that mocks classes, runs with real classes from
your project, has nginx embedded methods for openresty individual testing. Has a suite
of libraries preinstalled and you can specify libraries to install.

Mocka runs better in docker than in standalone - all you need to do is pull
the image and run it like so


Table of contents
----
1. [Installing](#installing)
2. [Running](#running)
	1. [Run with docker](#run-with-docker)
3. [Usage inside test classes](#ussage-inside-test-classes)
    1. [Mocking](#mock---mocking)
        - [Alter mock behaviour](#alter-mock-behaviour)
    2. [Running and skipping tests](#test-and-xtest---running-and-skipping)
        - [Running a test](#running-a-test)
        - [Running a test with exception](#running-a-test-that-throws-exception-or-you-know-it-will-fail)
        - [Skipping a test](#skipping-a-test)
    3. [Assertions](#assertions)
        - [assertEquals](#assertequals)
        - [assertNotEquals](#assertnotequals)
        - [assertNil](#assertnil)
        - [assertNotNil](#assertnotnil)
        - [assertTrue](#asserttrue)
        - [assertFalse](#assertfalse)
        - [Verify a mock has been called](#calls---verify-a-mock-has-been-called)
4. [Dependencies](#dependencies)
5. [Contributing](https://github.com/adobe/mocka/blob/master/CONTRIBUTING.md)
        

## Installing
- `sudo luarocks make mocka-1.0.0-1.rockspec`
- `sudo luarocks install luacov`

__Optional__:
- `lua -lluacov run_tests.lua`
- `luacov`
- `luacov-cobertura -o coverage_report.xml`

Suggest using:
 
__GitHub Pull Request Coverage Status__ and __Cobertura Plugin__


## Running

- `mocka <path_to_file>` - run a test file written in mocka framework style
- `mocka -t <path_to_file>` - run a test file written in mocka framework style (you can pass multiple -t files and the command will run all)
- `mocka <path_to_file> -p <path_to_root_of_project>` - run a test file and set the project root 
to the directory provided in -p (this helps a lot when working with packages). !The path to root of project
is more or less the same as for your luarocks module - where your lua files are all located!


If you need coverage report in a human readable form:

``` 
   luacov
   luacov-cobertura -o coverage_report.xml
```

### Run with docker
#### Build docker image and tag it with latest
```
make build-docker 
``` 
#### Run unit tests
```
make run-tests
``` 

#### Build docker image and run unit tests on local machine
```
make build-and-test 
``` 

## Usage inside test classes

### spy(...) - spying and stubbing

Spy whatever classes you want. Spies are reset after each test. And loose
whatever stubbing you did. That is why if any stub is needed than it should be
declared at beforeEach level. T2 is a global required field in this example - required
somewhere else.

Stubs treat even the async nature of nginx - ran on demand

```
    beforeEach(function()
        spy("test2", "run", function()
            print "Ok"
        end)
    end)
    test('it is', function()
        t2:run()
        calls(spy("test2").run, 1)
    end)
```

### mock(...) - Mocking

Mock whatever methods you want. Mocks are reset after each test. And loose
whatever stubbing you did. That is why if any stub is needed than it should be
declared at beforeEach level or test level.

``` 
    local classToMock = mock("path.to.class", {"method1", "method2"})
```

or mock all the methods dynamic

```
    local classToMock = mock("path.to.class")
```

#### Alter mock behaviour

``` 
    local classToMock = mock("path.to.class", {"method1", "method2"})
    when(classToMock).method1.fake(function(arg1, arg2)
        return arg1
    end)
```

or

```
    local classToMock = mock("path.to.class", {"method1", "method2"})
    when(classToMock).method1.doReturn = function(arg1, arg2)
            return arg1
    end
```

or

```
    local classToMock = mock("path.to.class", {"method1", "method2"})
    classToMock.__method1.doReturn = function(arg1, arg2)
        return arg1
    end
```

The only method that you don't want to alter if you mock is the __new__ function.

### test(...) and xtest(...) - Running and Skipping

#### Running a test
```
    test('describe what you are testing', function()
        assertEquals(true, true)
    end)
```


#### Running a test that throws exception or you know it will fail
```
    test('describe what you are testing', function()
        assertEquals(true, false)
    end, true)
```

#### Skipping a test
```
    xtest('describe what you are testing', function()
        assertEquals(true, true)
    end)
```

### Assertions

#### assertEquals 


```
    assertEquals(true, true)
```

```
    local one_object = {
        one = 1,
        two = 2
    }
    local second_object = {
        two = 2,
        one = 1
    }
    
    assertEquals(one_object, second_object)
```

```
    assertEqualse("string", "string")
```

```
    assertEquals(1,1)
```

```
    local first_array = {1, 2, 3}
    local second_array = {1, 2, 3}
    assertEquals(first_array, second_array)
```

#### assertNotEquals

```
    local first_array = {1, 2, 3}
    local second_array = {2, 1, 3}
    assertNotEquals(first_array, second_array)
```

#### assertNil

```
    assertNil(x)
```

#### assertNotNil

```
    local x = "string"
    assertNotNil(x)
```

#### assertTrue

```
    local x = 3 < 5
    assertTrue(x)
```

#### assertFalse

```
    local x = 3 > 5
    assertFalse(x)
```

#### calls(...) - verify a mock has been called

```
    local classToMock = mock("class", {"method"})
    calls(classToMock.__method, 1)
```

```
    local classToMock = mock("class", {"method"})
    calls(classToMock.__method, 1, arg2, arg1)
```

## Dependencies

This dependencies apply for docker

- [luacov-cobertura](https://github.com/britzl/luacov-cobertura) - MIT
- [luacheck](https://github.com/mpeterv/luacheck) - MIT
- [ldoc](https://stevedonovan.github.io/ldoc/)
- [jsonpath](https://github.com/mrpace2/lua-jsonpath) - MIT
- [lua-cjson](https://github.com/mpx/lua-cjson) - MIT
- [luabitop](http://bitop.luajit.org/index.html) - MIT
- [lua-resty-iputils](https://github.com/hamishforbes/lua-resty-iputils) - MIT
