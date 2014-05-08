/**
 * @license almond 0.2.9 Copyright (c) 2011-2014, The Dojo Foundation All Rights Reserved.
 * Available via the MIT or new BSD license.
 * see: http://github.com/jrburke/almond for details
 */
//Going sloppy to avoid 'use strict' string cost, but strict practices should
//be followed.
/*jslint sloppy: true */
/*global setTimeout: false */

/**
 * Modified for use in the quadcopter.
 * Modifications:
 * - NodeJS compatibility removed, regex is not supported: jsSuffixRegExp = /\.js$/;
 * - hasProp implementation changed to overcome limitation of not implemented Object.prototype.hasOwnProperty method
 * - Added a rudimentary "context" so that modules can be overridden during testing
 * - Added the ability for a client to get the names of all of the defined modules
 * - removed define.amd: its not used
 * - removed _defined: its not used
 * - dont define requirejs, its not used
 * - replace throw new Error with ReportError, Error isn't defined and throws isn't implemeted on an Espruino.
 * - remove common module support
 * - removed plugin support
 * - remove normalization as files don't need to be loaded from disk
 */

var require, define;
(function (undef) {
    var main, req, makeMap, handlers, deepCopy,
        config = {},
        aps = [].slice,
        context = {
          defined: {},
          defining: {},
          definedInContext: {},
          overrides: {},
          waiting: {}
        };

    function hasProp(obj, prop) {
        return (prop in obj);
    }

    function makeRequire(relName, forceSync) {
        return function () {
            //A version of a require function that passes a moduleName
            //value for items that may need to
            //look up paths relative to the moduleName
            return req.apply(undef, aps.call(arguments, 0).concat([relName, forceSync]));
        };
    }

    function makeLoad(depName) {
        return function (value) {
            context.defined[depName] = value;
        };
    }

    function callDep(name) {
        if (hasProp(context.overrides, name)) {
            return context.overrides[name];
        }

        if (hasProp(context.waiting, name)) {
            var args = context.waiting[name];
            delete context.waiting[name];
            context.defining[name] = true;
            main.apply(undef, args);
        }

        if (!hasProp(context.defined, name) && !hasProp(context.defining, name)) {
            ReportError('No ' + name);
            return -1;
        }
        return context.defined[name];
    }

    function splitPrefix(name) {
        return [undefined, name];
    }

    /**
     * Makes a name map, normalizing the name, and using a plugin
     * for normalization if necessary. Grabs a ref to plugin
     * too, as an optimization.
     */
    makeMap = function (name, relName) {
        //Using ridiculous property names for space reasons
        return {
            f: name,
            n: name
        };
    };

    function makeConfig(name) {
        return function () {
            return (config && config.config && config.config[name]) || {};
        };
    }

    handlers = {
        require: function (name) {
            return makeRequire(name);
        },
        exports: function (name) {
            var e = context.defined[name];
            if (typeof e !== 'undefined') {
                return e;
            } else {
                return (context.defined[name] = {});
            }
        },
        module: function (name) {
            return {
                id: name,
                uri: '',
                exports: context.defined[name],
                config: makeConfig(name)
            };
        }
    };

    deepCopy = function(destination, source) {
      for (var property in source) {
        if (typeof source[property] === "object" && source[property] !== null && destination[property]) {
          deepCopy(destination[property], source[property]);
        } else {
          destination[property] = source[property];
        }
      }
      return destination;
    };

    main = function (name, deps, callback, relName) {
        var depName, ret, map, i,
            args = [],
            callbackType = typeof callback,
            usingExports;

        //Use name if no relName
        relName = relName || name;

        //Call the callback to define the module, if necessary.
        if (callbackType === 'undefined' || callbackType === 'function') {
            //Pull out the defined dependencies and pass the ordered
            //values to the callback.
            //Default to [require, exports, module] if no deps
            deps = !deps.length && callback.length ? ['require', 'exports', 'module'] : deps;
            for (i = 0; i < deps.length; i += 1) {
                map = makeMap(deps[i], relName);
                depName = map.f;

                //Fast path CommonJS standard dependencies.
                if (depName === "require") {
                    args[i] = handlers.require(name);
                } else if (depName === "exports") {
                    //CommonJS module spec 1.1
                    args[i] = handlers.exports(name);
                    usingExports = true;
                } else if (hasProp(context.defined, depName) ||
                           hasProp(context.waiting, depName) ||
                           hasProp(context.defining, depName) ||
                           hasProp(context.overrides, depName)) {
                    args[i] = callDep(depName);
                } else if (map.p) {
                    map.p.load(map.n, makeRequire(relName, true), makeLoad(depName), {});
                    args[i] = context.defined[depName];
                } else {
                    ReportError(name + ' missing ' + depName);
                    return -1;
                }
            }

            ret = callback ? callback.apply(context.defined[name], args) : undefined;

            if (name) {
                if (ret !== undef || !usingExports) {
                    //Use the return value from the function.
                    context.defined[name] = ret;
                }
            }
        } else if (name) {
            //May just be an object definition for the module. Only
            //worry about defining if have a module name.
            context.defined[name] = callback;
        }
    };

    require = req = function (deps, callback, relName, forceSync, alt) {
        if (typeof deps === "string") {
            if (handlers[deps]) {
                //callback in this case is really relName
                return handlers[deps](callback);
            }
            //Just return the module wanted. In this scenario, the
            //deps arg is the module name, and second arg (if passed)
            //is just the relName.
            //Normalize module name, if it contains . or ..
            return callDep(makeMap(deps, callback).f);
        } else if (!deps.splice) {
            //deps is a config object, not an array.
            config = deps;
            if (config.deps) {
                req(config.deps, config.callback);
            }
            if (!callback) {
                return;
            }

            if (callback.splice) {
                //callback is an array, which means it is a dependency list.
                //Adjust args if there are dependencies
                deps = callback;
                callback = relName;
                relName = null;
            } else {
                deps = undef;
            }
        }

        //Support require(['a'])
        callback = callback || function () {};

        //If relName is a function, it is an errback handler,
        //so remove it.
        if (typeof relName === 'function') {
            relName = forceSync;
            forceSync = alt;
        }

        //Simulate async callback;
        if (forceSync) {
            main(undef, deps, callback, relName);
        } else {
            //Using a non-zero value because of concern for what old browsers
            //do, and latest browsers "upgrade" to 4 if lower value is used:
            //http://www.whatwg.org/specs/web-apps/current-work/multipage/timers.html#dom-windowtimers-settimeout:
            //If want a value immediately, use require('id') instead -- something
            //that works in almond on the global level, but not guaranteed and
            //unlikely to work in other AMD implementations.
            setTimeout(function () {
                main(undef, deps, callback, relName);
            }, 4);
        }

        return req;
    };

    /**
     * Just drops the config on the floor, but returns req in case
     * the config return value is used.
     */
    req.config = function (cfg) {
        return req(cfg);
    };

    define = function (name, deps, callback) {

        //This module may not have dependencies
        if (!deps.splice) {
            //deps is not an array, so probably means
            //an object literal or factory function for
            //the value. Adjust args.
            callback = deps;
            deps = [];
        }

        if (!hasProp(context.defined, name) && !hasProp(context.waiting, name)) {
            context.waiting[name] = [name, deps, callback];
            context.definedInContext[name] = [name, deps, callback];
        }
    };

    define.newContext = function() {
        context.waiting = deepCopy({}, context.definedInContext);
        context.defined = {};
        context.defining = {};
        context.overrides = {};
    };

    define.all = function() { return Object.keys(context.definedInContext); };

    define.override = function(name, value) {
        context.overrides[name] = value;
    };
}());
