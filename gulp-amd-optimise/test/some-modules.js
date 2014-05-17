
define('e', ['b', 'c'], function(b, c) { return b + c + 'e'; });

define('a', function() { return 'a'; });

define('b', ['a'], function(a) { return a + 'b'; });

define('c', ['b', 'a'], function(b, a) { return b + a + 'c'; });

define('h', ['g', 'e'], function(g, e) { return g + e + 'h'; });

define('d', [], function() { return 'd'; });

define('g', ['f', 'b'], function(f, b) { return f + b + 'g'; });

define('f', function() { return 'f'; });
