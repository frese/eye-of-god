var prefs = {

    data: {},

    load: function () {
        var the_cookie = document.cookie.split(';');
        if (the_cookie[0]) {
            this.data = unescape(the_cookie[0]).parseJSON();
        }
        return this.data;
    },

    save: function (expires, path) {
        var d = expires || new Date(2020, 02, 02);
        var p = path || '/';
        document.cookie = escape(this.data.toJSONString())
                          + ';path=' + p
                          + ';expires=' + d.toUTCString();
    }

}