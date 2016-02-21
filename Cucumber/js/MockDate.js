function TimeManager(time) {
    if(time) {
        this.now = time;
    } else {
        this.now = new Date().getTime();
    }
}

TimeManager.prototype.advanceTime = function(time) {
    this.now += time;
};

function MockDate(original, timeManager) {
    function mockDate() {
        var that = this;

        // Built-in constructors not functional enough
        if (arguments.length === 0) {
            // TODO: Fake this to a specific time
            this.date = new original(timeManager.now);
        } else if (arguments.length === 1) {
            this.date = new original(arguments[0]);
        } else if (arguments.length === 2) {
            this.date = new original(arguments[0], arguments[1]);
        } else if (arguments.length === 3) {
            this.date = new original(arguments[0], arguments[1], arguments[2]);
        } else if (arguments.length === 4) {
            this.date = new original(arguments[0], arguments[1], arguments[2], arguments[3]);
        } else if (arguments.length === 5) {
            this.date = new original(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
        } else {
            // Throw an error just in case, I'm not sure if other ctors are supported, if we know they're not
            // we could just apply 5 arguments
            throw Error("OMGARD");
        }

        // Built-ins not enumerable, yay
        ["getDate", "getDay", "getFullYear", "getHours", "getMilliseconds", "getMinutes", "getMonth", "getSeconds", "getTime", "getTimezoneOffset", "getUTCDate", "getUTCDay", "getUTCFullYear", "getUTCHours", "getUTCMilliseconds", "getUTCMinutes", "getUTCMonth", "getUTCSeconds", "getYear", "setDate", "setFullYear", "setHours", "setMilliseconds", "setMinutes", "setMonth", "setSeconds", "setTime", "setUTCDate", "setUTCFullYear", "setUTCHours", "setUTCMilliseconds", "setUTCMinutes", "setUTCMonth", "setUTCSeconds", "setYear", "toDateString", "toGMTString", "toISOString", "toJSON", "toLocaleDateString", "toLocaleString", "toLocaleTimeString", "toString", "toTimeString", "toUTCString"]
          .forEach(function(method) {
            that[method] = function() {
                return that.date[method].apply(that.date, arguments);
            };
        });
    }

    mockDate.prototype.toJSON = function() { return this.date.toJSON(); };
    mockDate.prototype.valueOf = function() { return this.date.getTime(); };

    mockDate.now = function(){ return (new mockDate()).getTime(); };
    mockDate.parse = original.parse; // TODO: fix
    mockDate.UTC = original.UTC; // TODO: fix

    return mockDate;
}

window.TimeManager = TimeManager;
window.MockDate = MockDate;
