var One = (function () {
    function One(foo, bar) {
        this.bar = "abc";
        this.priv = null;
        this.b;
    }
    One.prototype.foo = function () {
    };
    return One;
})();
exports.One = One;
//# sourceMappingURL=one.js.map
