
define('a', ['b'], function(b) { return b + 'a'; });

define('b', ['a'], function(a) { return a + 'b'; });
